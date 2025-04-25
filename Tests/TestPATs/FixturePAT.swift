import MockoloFramework

@Fixture enum simplePat {
    protocol Foo {}

    /// @mockable(typealias: T = String)
    public protocol FooBar: Foo {
        associatedtype T
    }

    @Fixture enum parent {
        public class FooMock: Foo {
            public init() { }

            public typealias T = String
        }
    }

    @Fixture enum expected {
        public class FooBarMock: FooBar {
            public init() { }

            public typealias T = String
        }
    }
}

@Fixture enum patOverride {
    /// @mockable(typealias: T = Any; U = Hashable & Codable; R = (String, Int); S = AnyObject)
    protocol Foo {
        associatedtype T
        associatedtype U
        associatedtype R
        associatedtype S
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }

            typealias T = Any
            typealias U = Hashable & Codable
            typealias R = (String, Int)
            typealias S = AnyObject
        }
    }
}

@Fixture enum patPartialOverride {
    /// @mockable(typealias: U = [Any])
    protocol Foo {
        associatedtype T
        associatedtype U: Collection where U.Element == T
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }
            typealias T = Any
            typealias U = [Any]
        }
    }
}

@Fixture enum overrideParentPAT {
    /// @mockable
    protocol ProtocolA {
        associatedtype ContextType
    }
    /// @mockable(typealias: ContextType = Void)
    protocol ProtocolA2: ProtocolA {}

    /// @mockable(typealias: ContextType = Int)
    protocol ProtocolB {
        associatedtype ContextType
    }
    /// @mockable(typealias: ContextType = Void)
    protocol ProtocolB2: ProtocolB {}

    /// @mockable(typealias: ContextType = Int)
    protocol ProtocolC {
        associatedtype ContextType
    }
    /// @mockable
    protocol ProtocolC2: ProtocolC {}

    @Fixture enum expected {
        class ProtocolAMock: ProtocolA {
            init() { }

            typealias ContextType = Any
        }

        class ProtocolA2Mock: ProtocolA2 {
            init() { }

            typealias ContextType = Void
        }

        class ProtocolBMock: ProtocolB {
            init() { }

            typealias ContextType = Int
        }

        class ProtocolB2Mock: ProtocolB2 {
            init() { }

            typealias ContextType = Void
        }

        class ProtocolCMock: ProtocolC {
            init() { }

            typealias ContextType = Int
        }

        class ProtocolC2Mock: ProtocolC2 {
            init() { }

            typealias ContextType = Int
        }
    }
}

@Fixture enum protocolWithTypealias {
    /// @mockable
    public protocol SomeType {
        typealias Key = String
        var key: Key { get }
    }

    @Fixture enum expected {
        public class SomeTypeMock: SomeType {
            public init() { }
            public init(key: Key) {
                self._key = key
            }
            public typealias Key = String

            private var _key: Key!
            public var key: Key {
                get { return _key }
                set { _key = newValue }
            }
        }
    }
}

@Fixture enum patDefaultType {
    struct MyID: Identifiable {
        var id: Int
    }

    /// @mockable
    protocol Foo {
        associatedtype T
        associatedtype U = String
        associatedtype S: Identifiable, Sendable = MyID where S.ID == Int
    }

    @Fixture enum expected {
        class FooMock<S: Identifiable & Sendable, T, U>: Foo where S.ID == Int {
            init() { }

            // Unavailable due to the presence of generic constraints
            // typealias S = MyID

            // Unavailable due to the presence of generic constraints
            // typealias U = String
        }
    }
}

@Fixture enum patWithConditions {
    /// @mockable
    public protocol Foo {
        associatedtype T: StringProtocol, Sendable
    }

    /// @mockable(typealias: T = String)
    public protocol Bar {
        associatedtype T: StringProtocol, Sendable
    }

    /// @mockable
    public protocol Baz {
        associatedtype T where T: StringProtocol, T: Sendable
    }

    @Fixture enum expected {
        public class FooMock<T: StringProtocol & Sendable>: Foo {
            public init() { }
        }

        public class BarMock: Bar {
            public init() { }
            public typealias T = String
        }

        public class BazMock<T>: Baz where T: StringProtocol, T: Sendable {
            public init() { }
        }
    }
}
#if compiler(>=6.0)
@Fixture enum patWithParentCondition {
    /// @mockable
    protocol Foo where T: Equatable {
        associatedtype T
    }

    /// @mockable(typealias: T = Int)
    protocol Bar where T: Equatable {
        associatedtype T
    }

    /// @mockable(typealias: U = Int)
    protocol Baz where T: Equatable {
        associatedtype T
        associatedtype U
    }

    /// @mockable
    protocol Qux where T: Collection {
        associatedtype T = Int
    }

    @Fixture enum expected {
        class FooMock<T>: Foo where T: Equatable {
            init() { }
        }

        class BarMock<T>: Bar where T: Equatable {
            init() { }

            // Unavailable due to the presence of generic constraints
            // typealias T = Int
        }

        class BazMock<T, U>: Baz where T: Equatable {
            init() { }

            // Unavailable due to the presence of generic constraints
            // typealias U = Int
        }

        class QuxMock<T>: Qux where T: Collection {
            init() { }

            // Unavailable due to the presence of generic constraints
            // typealias T = Int
        }
    }
}

@Fixture enum patNameCollision {
    protocol Foo {
        associatedtype T = Int
    }

    protocol Bar {
        associatedtype T: StringProtocol
    }

    /// @mockable
    protocol Baz: Foo, Bar {
    }

    protocol Animal {
        associatedtype T: Identifiable & Sendable where T.ID == String
    }

    /// @mockable
    protocol Dog: Bar, Animal {
    }

    /// @mockable
    protocol Cat: Bar where T: Identifiable & Sendable, T.ID == String {
    }

    @Fixture enum expected {
        class BazMock<T: StringProtocol>: Baz {
            init() { }
        }

        class DogMock<T: StringProtocol & Identifiable & Sendable>: Dog where T.ID == String {
            init() { }
        }

        class CatMock<T: StringProtocol>: Cat where T: Identifiable & Sendable, T.ID == String {
            init() { }
        }
    }
}
#endif
