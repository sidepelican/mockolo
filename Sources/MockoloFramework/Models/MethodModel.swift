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

public enum MethodKind: Equatable {
    case funcKind
    case initKind(required: Bool, override: Bool)
    case subscriptKind
}

struct MethodModel: Model {
    var name: String
    var returnType: SwiftType
    var accessLevel: String
    var kind: MethodKind
    var offset: Int64
    var length: Int64
    var attributes: [String]? = nil
    var genericTypeParams: [ParamModel]
    var genericWhereClause: String? = nil
    var params: [ParamModel]
    var processed: Bool
    var modelDescription: String? = nil
    var isStatic: Bool
    var isAsync: Bool
    var throwing: ThrowingKind
    var funcsWithArgsHistory: [String]
    var customModifiers: [String : Modifier]
    var modelType: ModelType {
        return .method
    }

    var filePath: String = ""
    var data: Data? = nil

    private var staticKind: String {
        return isStatic ? .static : ""
    }
    
    /// This is used to uniquely identify methods with the same signature and different generic requirements
    var genericWhereClauseToSignatureComponent: String {
        guard let genericWhereClause else {
            return ""
        }
        let typeRequirementSyntax = ":"
        let typeEqualitySyntax = "=="
        
        var signatureComponents: [String] = []
        
        genericWhereClause.deletingPrefix("where").components(separatedBy: ",").forEach { requirement in
            if requirement.contains(typeRequirementSyntax) {
                let components = requirement.components(separatedBy: typeRequirementSyntax).map{ $0.trimmingCharacters(in: .whitespaces) }
                guard let key = components.first, let value = components.last else {
                    return
                }
                let valueDescription = value.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "&", with: "And")
                signatureComponents.append(contentsOf: [key, valueDescription])
            } else if requirement.contains(typeEqualitySyntax) {
                let components = requirement.components(separatedBy: typeEqualitySyntax).map{ $0.trimmingCharacters(in: .whitespaces) }
                guard let key = components.first, let value = components.last else {
                    return
                }
                signatureComponents.append(contentsOf: [key, value])
            }
        }
        
        return signatureComponents.map { component in
            var newComponent = component
            newComponent.removeAll(where: { $0 == "."})
            return newComponent
        }.joined()
    }

    var isInitializer: Bool {
        if case .initKind(_, _) = kind {
            return true
        }
        return false
    }

    var isSubscript: Bool {
        if case .subscriptKind = kind {
            return true
        }
        return false
    }

    var signatureComponents: [String] {
        let paramLabels = self.params.map {$0.label != "_" ? $0.label : ""}
        let paramNames = self.params.map(\.name)
        let paramTypes = self.params.map(\.type)
        let nameString = self.name
        var args = zip(paramLabels, paramNames).compactMap { (argLabel: String, argName: String) -> String? in
            let val = argLabel.isEmpty ? argName : argLabel
            if val.count < 2 || !nameString.lowercased().hasSuffix(val.lowercased()) {
                return val.capitalizeFirstLetter
            }
            return nil
        }

        let genericTypeNames = self.genericTypeParams.map { $0.name.capitalizeFirstLetter + $0.type.displayName }
        args.append(contentsOf: genericTypeNames)
        if genericWhereClause != nil {
            args.append(genericWhereClauseToSignatureComponent)
        }
        args.append(contentsOf: paramTypes.map(\.displayName))
        var displayType = returnType.displayName
        let capped = min(displayType.count, 32)
        displayType.removeLast(displayType.count-capped)
        args.append(displayType)
        args.append(self.staticKind)
        let ret = args.filter{ arg in !arg.isEmpty }
        return ret
    }

    var argsHistory: ArgumentsHistoryModel? {
        if isInitializer || isSubscript {
            return nil
        }

        return ArgumentsHistoryModel(name: name,
                                     genericTypeParams: genericTypeParams,
                                     params: params,
                                     isHistoryAnnotated: funcsWithArgsHistory.contains(name))
    }

    func handler() -> ClosureModel? {
        if isInitializer {
            return nil
        }

        return ClosureModel(name: name,
                            genericTypeParams: genericTypeParams,
                            paramNames: params.map(\.name),
                            paramTypes: params.map(\.type),
                            isAsync: isAsync,
                            throwing: throwing,
                            returnType: returnType)
    }

    var fullName: String {
        return self.name + self.signatureComponents.joined() + staticKind
    }

    func name(by level: Int) -> String {
        if level <= 0 {
            return name
        }
        let diff = level - self.signatureComponents.count
        let postfix = diff > 0 ? String(diff) : self.signatureComponents[level - 1]
        return name(by: level - 1) + postfix
    }

    func render(
        context: MethodRenderContext,
        arguments: GenerationArguments
    ) -> String? {
        let shouldOverride = context.annotatedTypeKind == .class
        if processed {
            var prefix = shouldOverride  ? "\(String.override) " : ""

            if case .initKind(required: let isRequired, override: _) = self.kind {
                if isRequired {
                    prefix = ""
                }
            }

            if let ret = modelDescription?.trimmingCharacters(in: .newlines) ?? self.data?.toString(offset: offset, length: length) {
                return prefix + ret
            }
            return nil
        }

        return applyMethodTemplate(name: name,
                                   kind: kind,
                                   arguments: arguments,
                                   isStatic: isStatic,
                                   customModifiers: customModifiers,
                                   isOverride: shouldOverride,
                                   genericTypeParams: genericTypeParams,
                                   genericWhereClause: genericWhereClause,
                                   params: params,
                                   returnType: returnType,
                                   accessLevel: accessLevel,
                                   argsHistory: argsHistory,
                                   handler: handler(),
                                   context: context)
    }
}
