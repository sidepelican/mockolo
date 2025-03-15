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
    /// Indicates whether this model can be used as a parameter to an initializer
    let canBeInitParam: Bool
    let processed: Bool
    let isStatic: Bool
    let storageKind: MockStorageKind
    let modelDescription: String?

    // FIXME: May cause unstable results during inheritance
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
         isStatic: Bool,
         storageKind: MockStorageKind,
         canBeInitParam: Bool,
         offset: Int64,
         modelDescription: String?,
         processed: Bool) {
        self.name = name
        self.type = type
        self.offset = offset
        self.isStatic = isStatic
        self.storageKind = storageKind
        self.canBeInitParam = canBeInitParam
        self.processed = processed
        self.accessLevel = acl ?? ""
        self.attributes = nil
        self.modelDescription = modelDescription
    }

    func render(
        context: RenderContext,
        arguments: GenerationArguments
    ) -> String? {
        guard let enclosingType = context.enclosingType else {
            return nil
        }
        let shouldOverride = context.annotatedTypeKind == .class
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
            if let combineVar = applyCombineVariableTemplate(name: name,
                                                             type: type,
                                                             encloser: enclosingType.typeName,
                                                             shouldOverride: shouldOverride,
                                                             isStatic: isStatic,
                                                             accessLevel: accessLevel,
                                                             combineTypes: context.metadata?.combineTypes) {
                return combineVar
            }
        }

        if let rxVar = applyRxVariableTemplate(name: name,
                                               type: type,
                                               encloser: enclosingType.typeName,
                                               rxTypes: context.metadata?.varTypes,
                                               shouldOverride: shouldOverride,
                                               useMockObservable: arguments.useMockObservable,
                                               allowSetCallCount: arguments.allowSetCallCount,
                                               isStatic: isStatic,
                                               accessLevel: accessLevel) {
            return rxVar
        }

        return applyVariableTemplate(name: name,
                                     type: type,
                                     encloser: enclosingType.typeName,
                                     isStatic: isStatic,
                                     customModifiers: context.metadata?.modifiers,
                                     allowSetCallCount: arguments.allowSetCallCount,
                                     shouldOverride: shouldOverride,
                                     accessLevel: accessLevel,
                                     context: context,
                                     arguments: arguments)
    }
}
