//
//  Copyright (c) 2018. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Algorithms

struct LookupResult {
    var models = [any Model]()
    // Used to keep track of types that were already mocked
    var processedModels = [any Model]()
    // Gather attributes declared in current or parent protocols
    var attributes = [String]()
    // Gather inherited types declared in current or parent protocols
    var inheritedTypes = Set<String>()
    // Gather filepaths used for imports
    var paths = [String]()

    fileprivate mutating func append(_ other: LookupResult) {
        self.models.append(contentsOf: other.models)
        self.processedModels.append(contentsOf: other.processedModels)
        self.attributes.append(contentsOf: other.attributes)
        self.inheritedTypes.formUnion(other.inheritedTypes)
        self.paths.append(contentsOf: other.paths)
    }
}

/// Used to resolve inheritance, uniquify duplicate entities, and compute potential init params.

/// Resolves inheritance by looking up the given protocol map and inheritance map
/// @param key The entity name to look up
/// @param protocolMap Used to look up the current entity and its inheritance types
/// @param inheritanceMap Used to look up inherited types if not contained in protocolMap
/// @returns a list of models representing sub-entities of the current entity, a list of models processed in dependent mock files if exists,
///          cumulated attributes, cumulated inherited types, and a map of filepaths and file contents (used for import lines lookup later).
func lookupEntities(key: String,
                    declType: FindTargetDeclType,
                    protocolMap: [String: Entity],
                    inheritanceMap: [String: Entity]) -> LookupResult {
    var result = LookupResult()

    // Look up the mock entities of a protocol specified by the name.
    if let current = protocolMap[key] {
        let sub = current.entityNode.subContainer(metadata: current.metadata, declType: declType, path: current.filepath, isProcessed: current.isProcessed)
        result.models.append(contentsOf: sub.members)
        if !current.isProcessed {
            result.attributes.append(contentsOf: sub.attributes)
        }
        result.inheritedTypes.formUnion(current.entityNode.inheritedTypes)
        result.paths.append(current.filepath)

        if declType == .protocolType { // TODO: remove this once parent protocol (current decl = classtype) handling is resolved.
            // If the protocol inherits other protocols, look up their entities as well.
            for parent in current.entityNode.inheritedTypes {
                if parent != .class, parent != .anyType, parent != .anyObject {
                    let parentResult = lookupEntities(key: parent, declType: declType, protocolMap: protocolMap, inheritanceMap: inheritanceMap)
                    result.append(parentResult)
                }
            }
        }
    } else if let parentMock = inheritanceMap["\(key)Mock"], declType == .protocolType {
        // If the parent protocol is not in the protocol map, look it up in the input parent mocks map.
        let sub = parentMock.entityNode.subContainer(metadata: parentMock.metadata, declType: declType, path: parentMock.filepath, isProcessed: parentMock.isProcessed)
        result.processedModels.append(contentsOf: sub.members)
        if !parentMock.isProcessed {
            result.attributes.append(contentsOf: sub.attributes)
        }
        result.paths.append(parentMock.filepath)
    }
    
    return result
}


/// Uniquify multiple entities with the same name, e.g. func signature, using the verbosity level
/// @param group The dictionary containing entity name and corresponding models
/// @param level The verbosiy level used for uniquing entity names
/// @param nameByLevelVisited Used to look up whether an entity name has already been used and thus needs
///                           to be differentiated
/// @param fullNameVisited Used to look up an entity full name to detect true duplicates (e.g.
///        overloaded functions in multiple parent protocols)
/// @returns a dictionary with unique entity names and corresponding models
private func uniquifyDuplicates(group: [String: [any Model]],
                                level: Int,
                                nameByLevelVisited: [String: any Model]?,
                                fullNameVisited: [String]) -> [String: any Model] {
    
    var bufferNameByLevelVisited = [String: any Model]()
    var bufferFullNameVisited = [String]()
    for (key, models) in group {
        if let nameByLevelVisited, nameByLevelVisited[key] != nil {
            // An entity with the given key already exists, so look up a more verbose name for these entities
            let subgroup = Dictionary(grouping: models, by: { (modelElement: (any Model)) -> String in
                return modelElement.name(by: level + 1)
            })
            if !fullNameVisited.isEmpty {
                bufferFullNameVisited.append(contentsOf: fullNameVisited)
            }
            let subresult = uniquifyDuplicates(group: subgroup, level: level+1, nameByLevelVisited: bufferNameByLevelVisited, fullNameVisited: bufferFullNameVisited)
            bufferNameByLevelVisited.merge(subresult, uniquingKeysWith: { $1 })
        } else {
            // Check if full name has been looked up
            let (unvisited, visited) = models.partitioned(by: { fullNameVisited.contains($0.fullName) })

            if let first = unvisited.first {
                // If not, add it to the fullname map to keep track of duplicates
                if !visited.isEmpty {
                    bufferFullNameVisited.append(contentsOf: visited.map{$0.fullName})
                }
                bufferFullNameVisited.append(first.fullName)
                
                // There could be multiple entities with the same name key; add the first one to
                // a buffer and use a more verbose name key for the rest to differentiate them
                bufferNameByLevelVisited[key] = first
                let nextModels = unvisited[1...]
                let subgroup = Dictionary(grouping: nextModels, by: { (modelElement: (any Model)) -> String in
                    let distinctName = modelElement.name(by: level + 1)
                    return distinctName
                })
                
                let subresult = uniquifyDuplicates(group: subgroup, level: level+1, nameByLevelVisited: bufferNameByLevelVisited, fullNameVisited: bufferFullNameVisited)
                bufferNameByLevelVisited.merge(subresult, uniquingKeysWith: { $1 })
            }
        }
    }
    return bufferNameByLevelVisited
}

/// Uniquify multiple entities with the same name
/// @param models The entity models that possibly contain duplciates
/// @param exclude The models that are used for lookup only
/// @param fullnames Used to look up full identifiers
/// @returns A map of unique models
func uniqueEntities(`in` models: [any Model], exclude: [String: any Model], fullnames: [String]) -> [String: any Model] {
    return uniquifyDuplicates(group: Dictionary(grouping: models) { $0.name(by: 0) }, level: 0, nameByLevelVisited: exclude, fullNameVisited: fullnames)
}

