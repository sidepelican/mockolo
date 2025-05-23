import MockoloFramework

let nestedProtocol = """
@MainActor final class FooView: UIView {
    /// @mockable
    @MainActor protocol Delegate: AnyObject {
        func onTapButton(_ button: UIButton)
    }

    weak var delegate: Delegate? 
}

extension AAA {
    actor BBB {
        /// @mockable
        protocol CCC {
        }
    }
}
"""

let nestedProtocolMock = """
extension FooView {
    
    class DelegateMock: Delegate {
        init() { }


        private(set) var onTapButtonCallCount = 0
        var onTapButtonHandler: ((UIButton) -> ())?
        func onTapButton(_ button: UIButton) {
            onTapButtonCallCount += 1
            if let onTapButtonHandler = onTapButtonHandler {
                onTapButtonHandler(button)
            }
            
        }
    }
}
extension AAA.BBB {
    
    class CCCMock: CCC {
        init() { }
    
    
    }
}
"""

let nestedProtocolInGeneric = """
actor Foo<T> {
    /// @mockable
    protocol NG1 {
        func requirement() -> Int
    }
}

enum Bar<T> {
    struct Baz {
        /// @mockable
        protocol NG2 {
            func requirement() -> Int
        }
    }
}

/// @mockable
protocol OK<T> {
    associatedtype T
    func requirement() -> T
}
"""

let nestedProtocolInGenericMock = """
class OKMock: OK {
    init() { }

    typealias T = Any

    private(set) var requirementCallCount = 0
    var requirementHandler: (() -> T)?
    func requirement() -> T {
        requirementCallCount += 1
        if let requirementHandler = requirementHandler {
            return requirementHandler()
        }
        fatalError("requirementHandler returns can't have a default value thus its handler must be set")
    }
}
"""
