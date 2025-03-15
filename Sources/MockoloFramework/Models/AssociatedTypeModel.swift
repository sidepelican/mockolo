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

import Foundation

final class AssociatedTypeModel: Model {
    let name: String
    let defaultType: SwiftType?
    let offset: Int64
    let length: Int64
    let accessLevel: String
    let overrideTypes: [String: String]?

    var modelType: ModelType {
        return .associatedType
    }

    init(name: String, defaultTypeName: String?, acl: String?, overrideTypes: [String: String]?, offset: Int64, length: Int64) {
        self.name = name
        self.accessLevel = acl ?? ""
        self.offset = offset
        self.length = length
        self.overrideTypes = overrideTypes
        // If there's an override typealias value, set it to type
        self.defaultType = if let val = overrideTypes?[self.name] {
            SwiftType(val)
        } else {
            if let defaultTypeName {
                defaultTypeName.isEmpty ? SwiftType(String.anyType) : SwiftType(defaultTypeName)
            } else {
                nil
            }
        }
    }

    var fullName: String {
        return self.name + (self.defaultType?.displayName ?? "")
    }

    func name(by level: Int) -> String {
        return fullName
    }

    func render(
        context: RenderContext,
        arguments: GenerationArguments
    ) -> String? {
        guard let defaultType else {
            return nil
        }

        var aclStr = accessLevel
        if !aclStr.isEmpty {
            aclStr = aclStr + " "
        }

        return "\(1.tab)\(aclStr)\(String.typealias) \(name) = \(defaultType.typeName)"
    }
}
