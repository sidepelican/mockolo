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

    var name: String
    var type: SwiftType
    var offset: Int64
    let accessLevel: String
    let attributes: [String]?
    let encloserType: DeclType
    /// Indicates whether this model can be used as a parameter to an initializer
    var canBeInitParam: Bool
    let processed: Bool
    var filePath: String = ""
    var isStatic = false
    var shouldOverride = false
    let storageKind: MockStorageKind
    var rxTypes: [String: String]?
    var customModifiers: [String: Modifier]?
    var modelDescription: String? = nil
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
         typeName: String,
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
        self.name = name.trimmingCharacters(in: .whitespaces)
        self.type = SwiftType(typeName.trimmingCharacters(in: .whitespaces))
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

    func render(
        with identifier: String,
        context: MemberRenderContext,
        arguments: GenerationArguments
    ) -> String? {
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

        if !arguments.disableCombineDefaultValues {
            if let combineVar = applyCombineVariableTemplate(name: identifier,
                                                             type: type,
                                                             encloser: context.enclosingType.typeName,
                                                             shouldOverride: shouldOverride,
                                                             isStatic: isStatic,
                                                             accessLevel: accessLevel) {
                return combineVar
            }
        }

        if let rxVar = applyRxVariableTemplate(name: identifier,
                                               type: type,
                                               encloser: context.enclosingType.typeName,
                                               rxTypes: rxTypes,
                                               shouldOverride: shouldOverride,
                                               useMockObservable: arguments.useMockObservable,
                                               allowSetCallCount: arguments.allowSetCallCount,
                                               isStatic: isStatic,
                                               accessLevel: accessLevel) {
            return rxVar
        }

        return applyVariableTemplate(name: identifier,
                                     type: type,
                                     encloser: context.enclosingType.typeName,
                                     isStatic: isStatic,
                                     customModifiers: customModifiers,
                                     allowSetCallCount: arguments.allowSetCallCount,
                                     shouldOverride: shouldOverride,
                                     accessLevel: accessLevel,
                                     context: context)
    }
}
