import Foundation

final class VariableModel: Model {
    struct GetterEffects: Equatable {
        var isAsync: Bool
        var throwing: ThrowingKind
        static let empty: GetterEffects = .init(isAsync: false, throwing: .none)
    }

    enum MockStorageKind {
        case stored(needsSetCount: Bool)
        case computed(GetterEffects)
    }

    let name: String
    let type: SwiftType
    let offset: Int64
    let accessLevel: String
    let attributes: [String]?
    let encloserType: DeclType
    /// Indicates whether this model can be used as a parameter to an initializer
    let canBeInitParam: Bool
    let processed: Bool
    let isStatic: Bool
    let shouldOverride: Bool
    let storageKind: MockStorageKind
    let rxTypes: [String: String]?
    let customModifiers: [String: Modifier]?
    let modelDescription: String?

    var combineType: CombineType?
    var wrapperAliasModel: VariableModel?
    var propertyWrapper: String?
    var modelType: ModelType {
        return .variable
    }

    var fullName: String {
        let suffix = isStatic ? String.static : ""
        return name + suffix
    }

    var underlyingName: String {
        if type.defaultVal() == nil {
            return "_\(name)"
        }
        return name
    }

    init(name: String,
         type: SwiftType,
         acl: String?,
         encloserType: DeclType,
         isStatic: Bool,
         storageKind: MockStorageKind,
         canBeInitParam: Bool,
         offset: Int64,
         rxTypes: [String: String]?,
         customModifiers: [String: Modifier]?,
         modelDescription: String?,
         combineType: CombineType?,
         processed: Bool) {
        self.name = name
        self.type = type
        self.offset = offset
        self.isStatic = isStatic
        self.storageKind = storageKind
        self.shouldOverride = encloserType == .classType
        self.canBeInitParam = canBeInitParam
        self.processed = processed
        self.rxTypes = rxTypes
        self.customModifiers = customModifiers
        self.accessLevel = acl ?? ""
        self.attributes = nil
        self.encloserType = encloserType
        self.modelDescription = modelDescription
        self.combineType = combineType
    }

    func render(with identifier: String, encloser: String, useTemplateFunc: Bool = false, useMockObservable: Bool = false, allowSetCallCount: Bool = false, mockFinal: Bool = false, enableFuncArgsHistory: Bool = false, disableCombineDefaultValues: Bool = false) -> String? {
        if processed {
            guard let modelDescription = modelDescription?.trimmingCharacters(in: .newlines), !modelDescription.isEmpty else {
                return nil
            }

            var prefix = ""
            if let propertyWrapper = propertyWrapper, !modelDescription.contains(propertyWrapper) {
                prefix = "\(propertyWrapper) "
            }
            if shouldOverride, !name.isGenerated(type: type) {
                prefix += "\(String.override) "
            }

            return prefix + modelDescription
        }

        if !disableCombineDefaultValues {
            if let combineVar = applyCombineVariableTemplate(name: identifier,
                                                            type: type,
                                                            encloser: encloser,
                                                            shouldOverride: shouldOverride,
                                                            isStatic: isStatic,
                                                            accessLevel: accessLevel) {
                return combineVar
            }
        }

        if let rxVar = applyRxVariableTemplate(name: identifier,
                                               type: type,
                                               encloser: encloser,
                                               rxTypes: rxTypes,
                                               shouldOverride: shouldOverride,
                                               useMockObservable: useMockObservable,
                                               allowSetCallCount: allowSetCallCount,
                                               isStatic: isStatic,
                                               accessLevel: accessLevel) {
            return rxVar
        }

        return applyVariableTemplate(name: identifier,
                                     type: type,
                                     encloser: encloser,
                                     isStatic: isStatic,
                                     customModifiers: customModifiers,
                                     allowSetCallCount: allowSetCallCount,
                                     shouldOverride: shouldOverride,
                                     accessLevel: accessLevel)
    }
}
