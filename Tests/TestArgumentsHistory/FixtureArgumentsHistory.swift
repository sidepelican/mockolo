@Fixture enum argumentsHistoryWithAnnotation {
    /// @mockable(history: fooFunc = true; bazFunc = true)
    protocol Foo {
        func fooFunc(val: Int)
        func barFunc(for: [Int])
        func bazFunc(arg: String, default: Float)
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }


            private(set) var fooFuncCallCount = 0
            var fooFuncArgValues = [Int]()
            var fooFuncHandler: ((Int) -> ())?
            func fooFunc(val: Int) {
                fooFuncCallCount += 1
                fooFuncArgValues.append(val)
                if let fooFuncHandler = fooFuncHandler {
                    fooFuncHandler(val)
                }
            }

            private(set) var barFuncCallCount = 0
            var barFuncArgValues = [[Int]]()
            var barFuncHandler: (([Int]) -> ())?
            func barFunc(for: [Int]) {
                barFuncCallCount += 1
                barFuncArgValues.append(`for`)
                if let barFuncHandler = barFuncHandler {
                    barFuncHandler(`for`)
                }
            }

            private(set) var bazFuncCallCount = 0
            var bazFuncArgValues = [(arg: String, default: Float)]()
            var bazFuncHandler: ((String, Float) -> ())?
            func bazFunc(arg: String, default: Float) {
                bazFuncCallCount += 1
                bazFuncArgValues.append((arg, `default`))
                if let bazFuncHandler = bazFuncHandler {
                    bazFuncHandler(arg, `default`)
                }
            }
        }
    }
}

@Fixture enum argumentsHistoryWithAnnotationNotAllFuncCase {
    /// @mockable(history: fooFunc = true; bazFunc = true)
    protocol Foo {
        func fooFunc(val: Int)
        func barFunc(for: [Int])
        func bazFunc(arg: String, default: Float)
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }


            private(set) var fooFuncCallCount = 0
            var fooFuncArgValues = [Int]()
            var fooFuncHandler: ((Int) -> ())?
            func fooFunc(val: Int) {
                fooFuncCallCount += 1
                fooFuncArgValues.append(val)
                if let fooFuncHandler = fooFuncHandler {
                    fooFuncHandler(val)
                }

            }

            private(set) var barFuncCallCount = 0
            var barFuncHandler: (([Int]) -> ())?
            func barFunc(for: [Int]) {
                barFuncCallCount += 1
                if let barFuncHandler = barFuncHandler {
                    barFuncHandler(`for`)
                }

            }

            private(set) var bazFuncCallCount = 0
            var bazFuncArgValues = [(arg: String, default: Float)]()
            var bazFuncHandler: ((String, Float) -> ())?
            func bazFunc(arg: String, default: Float) {
                bazFuncCallCount += 1
                bazFuncArgValues.append((arg, `default`))
                if let bazFuncHandler = bazFuncHandler {
                    bazFuncHandler(arg, `default`)
                }

            }
        }
    }
}

@Fixture enum argumentsHistorySimpleCase {
    /// @mockable
    protocol Foo {
        func fooFunc()
        func barFunc(val: Int)
        func bazFunc(_ val: Int)
        func quxFunc(val: Int) -> String
        func quuxFunc(val1: String, val2: Float)
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }

            private(set) var fooFuncCallCount = 0
            var fooFuncHandler: (() -> ())?
            func fooFunc() {
                fooFuncCallCount += 1

                if let fooFuncHandler = fooFuncHandler {
                    fooFuncHandler()
                }
            }

            private(set) var barFuncCallCount = 0
            var barFuncArgValues = [Int]()
            var barFuncHandler: ((Int) -> ())?
            func barFunc(val: Int) {
                barFuncCallCount += 1
                barFuncArgValues.append(val)

                if let barFuncHandler = barFuncHandler {
                    barFuncHandler(val)
                }
            }

            private(set) var bazFuncCallCount = 0
            var bazFuncArgValues = [Int]()
            var bazFuncHandler: ((Int) -> ())?
            func bazFunc(_ val: Int) {
                bazFuncCallCount += 1
                bazFuncArgValues.append(val)

                if let bazFuncHandler = bazFuncHandler {
                    bazFuncHandler(val)
                }
            }

            private(set) var quxFuncCallCount = 0
            var quxFuncArgValues = [Int]()
            var quxFuncHandler: ((Int) -> String)?
            func quxFunc(val: Int) -> String {
                quxFuncCallCount += 1
                quxFuncArgValues.append(val)

                if let quxFuncHandler = quxFuncHandler {
                    return quxFuncHandler(val)
                }
                return ""
            }

            private(set) var quuxFuncCallCount = 0
            var quuxFuncArgValues = [(val1: String, val2: Float)]()
            var quuxFuncHandler: ((String, Float) -> ())?
            func quuxFunc(val1: String, val2: Float) {
                quuxFuncCallCount += 1
                quuxFuncArgValues.append((val1, val2))

                if let quuxFuncHandler = quuxFuncHandler {
                    quuxFuncHandler(val1, val2)
                }
            }
        }
    }
}

@Fixture enum argumentsHistoryTupleCase {
    /// @mockable(history: fooFunc = true)
    protocol Foo {
        func fooFunc(val: (Int, String))
        func barFunc(val1: (bar1: Int, String), val2: (bar3: Int, bar4: String))
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }

            private(set) var fooFuncCallCount = 0
            var fooFuncArgValues = [(Int, String)]()
            var fooFuncHandler: (((Int, String)) -> ())?
            func fooFunc(val: (Int, String)) {
                fooFuncCallCount += 1
                fooFuncArgValues.append(val)

                if let fooFuncHandler = fooFuncHandler {
                    fooFuncHandler(val)
                }
            }

            private(set) var barFuncCallCount = 0
            var barFuncArgValues = [(val1: (bar1: Int, String), val2: (bar3: Int, bar4: String))]()
            var barFuncHandler: (((bar1: Int, String), (bar3: Int, bar4: String)) -> ())?
            func barFunc(val1: (bar1: Int, String), val2: (bar3: Int, bar4: String)) {
                barFuncCallCount += 1
                barFuncArgValues.append((val1, val2))

                if let barFuncHandler = barFuncHandler {
                    barFuncHandler(val1, val2)
                }
            }
        }
    }
}

@Fixture enum argumentsHistoryOverloadedCase {
    /// @mockable
    protocol Foo {
        func fooFunc()
        func fooFunc(val1: Int)
        func fooFunc(val1: String)
        func fooFunc(val2: Int)
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }

            private(set) var fooFuncCallCount = 0
            var fooFuncHandler: (() -> ())?
            func fooFunc() {
                fooFuncCallCount += 1

                if let fooFuncHandler = fooFuncHandler {
                    fooFuncHandler()
                }
            }

            private(set) var fooFuncVal1CallCount = 0
            var fooFuncVal1ArgValues = [Int]()
            var fooFuncVal1Handler: ((Int) -> ())?
            func fooFunc(val1: Int) {
                fooFuncVal1CallCount += 1
                fooFuncVal1ArgValues.append(val1)

                if let fooFuncVal1Handler = fooFuncVal1Handler {
                    fooFuncVal1Handler(val1)
                }

            }

            private(set) var fooFuncVal1StringCallCount = 0
            var fooFuncVal1StringArgValues = [String]()
            var fooFuncVal1StringHandler: ((String) -> ())?
            func fooFunc(val1: String) {
                fooFuncVal1StringCallCount += 1
                fooFuncVal1StringArgValues.append(val1)

                if let fooFuncVal1StringHandler = fooFuncVal1StringHandler {
                    fooFuncVal1StringHandler(val1)
                }
            }

            private(set) var fooFuncVal2CallCount = 0
            var fooFuncVal2ArgValues = [Int]()
            var fooFuncVal2Handler: ((Int) -> ())?
            func fooFunc(val2: Int) {
                fooFuncVal2CallCount += 1
                fooFuncVal2ArgValues.append(val2)

                if let fooFuncVal2Handler = fooFuncVal2Handler {
                    fooFuncVal2Handler(val2)
                }
            }
        }
    }
}

@Fixture enum argumentsHistoryGenericsCase {
    /// @mockable
    protocol Foo {
        func fooFunc<T: StringProtocol>(val1: T, val2: T?)
        func barFunc<T: Sequence, U: Collection>(val: T) -> U
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }
            
            private(set) var fooFuncCallCount = 0
            var fooFuncArgValues = [(val1: Any, val2: Any?)]()
            var fooFuncHandler: ((Any, Any?) -> ())?
            func fooFunc<T: StringProtocol>(val1: T, val2: T?) {
                fooFuncCallCount += 1
                fooFuncArgValues.append((val1, val2))
                
                if let fooFuncHandler = fooFuncHandler {
                    fooFuncHandler(val1, val2)
                }
            }
            
            private(set) var barFuncCallCount = 0
            var barFuncArgValues = [Any]()
            var barFuncHandler: ((Any) -> Any)?
            func barFunc<T: Sequence, U: Collection>(val: T) -> U {
                barFuncCallCount += 1
                barFuncArgValues.append(val)
                
                if let barFuncHandler = barFuncHandler {
                    return barFuncHandler(val) as! U
                }
                fatalError("barFuncHandler returns can't have a default value thus its handler must be set")
            }
        }
    }
}

@Fixture enum argumentsHistoryInoutCase {
    /// @mockable
    protocol Foo {
        func fooFunc(val: inout Int)
        func barFunc(into val: inout Int)
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }


            private(set) var fooFuncCallCount = 0
            var fooFuncArgValues = [Int]()
            var fooFuncHandler: ((inout Int) -> ())?
            func fooFunc(val: inout Int) {
                fooFuncCallCount += 1
                fooFuncArgValues.append(val)
                if let fooFuncHandler = fooFuncHandler {
                    fooFuncHandler(&val)
                }

            }

            private(set) var barFuncCallCount = 0
            var barFuncArgValues = [Int]()
            var barFuncHandler: ((inout Int) -> ())?
            func barFunc(into val: inout Int) {
                barFuncCallCount += 1
                barFuncArgValues.append(val)
                if let barFuncHandler = barFuncHandler {
                    barFuncHandler(&val)
                }

            }
        }
    }
}

@Fixture enum argumentsHistoryHandlerCase {
    /// @mockable
    protocol Foo {
        func fooFunc(handler: () -> Int)
        func barFunc(val: Int, handler: (String) -> Void)
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }

            private(set) var fooFuncCallCount = 0
            var fooFuncHandler: ((() -> Int) -> ())?
            func fooFunc(handler: () -> Int) {
                fooFuncCallCount += 1

                if let fooFuncHandler = fooFuncHandler {
                    fooFuncHandler(handler)
                }
            }

            private(set) var barFuncCallCount = 0
            var barFuncArgValues = [Int]()
            var barFuncHandler: ((Int, (String) -> Void) -> ())?
            func barFunc(val: Int, handler: (String) -> Void) {
                barFuncCallCount += 1
                barFuncArgValues.append(val)

                if let barFuncHandler = barFuncHandler {
                    barFuncHandler(val, handler)
                }
            }
        }
    }
}

@Fixture enum argumentsHistoryEscapingTypealiasHandlerCase {
    typealias FooHandler = () -> Int
    typealias BarHandler = (String) -> Void

    /// @mockable
    protocol Foo {
        func fooFunc(handler: @escaping FooHandler)
        func barFunc(val: Int, handler: @escaping BarHandler)
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }

            private(set) var fooFuncCallCount = 0
            var fooFuncHandler: ((@escaping FooHandler) -> ())?
            func fooFunc(handler: @escaping FooHandler) {
                fooFuncCallCount += 1

                if let fooFuncHandler = fooFuncHandler {
                    fooFuncHandler(handler)
                }
            }

            private(set) var barFuncCallCount = 0
            var barFuncArgValues = [Int]()
            var barFuncHandler: ((Int, @escaping BarHandler) -> ())?
            func barFunc(val: Int, handler: @escaping BarHandler) {
                barFuncCallCount += 1
                barFuncArgValues.append(val)

                if let barFuncHandler = barFuncHandler {
                    barFuncHandler(val, handler)
                }
            }
        }
    }
}

@Fixture enum argumentsHistoryAutoclosureCase {
    /// @mockable
    protocol Foo {
        func fooFunc(handler: @autoclosure () -> Int)
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }

            private(set) var fooFuncCallCount = 0
            var fooFuncHandler: ((@autoclosure () -> Int) -> ())?
            func fooFunc(handler: @autoclosure () -> Int) {
                fooFuncCallCount += 1

                if let fooFuncHandler = fooFuncHandler {
                    fooFuncHandler(handler())
                }
            }
        }
    }
}

@Fixture enum argumentsHistoryStaticCase {
    /// @mockable
    protocol Foo {
        static func fooFunc(val: Int)
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }

            static private(set) var fooFuncCallCount = 0
            static var fooFuncArgValues = [Int]()
            static var fooFuncHandler: ((Int) -> ())?
            static func fooFunc(val: Int) {
                fooFuncCallCount += 1
                fooFuncArgValues.append(val)

                if let fooFuncHandler = fooFuncHandler {
                    fooFuncHandler(val)
                }
            }
        }
    }
}

@Fixture enum argumentsHistoryLabels {
    /// @mockable
    protocol Foo {
        func foo(arg0: Int, _ arg1: Double, first throws: String)
        func bar(_: Int, _: Void, _ _: Void)
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }

            private(set) var fooCallCount = 0
            var fooArgValues = [(arg0: Int, arg1: Double, throws: String)]()
            var fooHandler: ((Int, Double, String) -> ())?
            func foo(arg0: Int, _ arg1: Double, first throws: String) {
                fooCallCount += 1
                fooArgValues.append((arg0, arg1, `throws`))
                if let fooHandler = fooHandler {
                    fooHandler(arg0, arg1, `throws`)
                }

            }

            private(set) var barCallCount = 0
            var barArgValues = [(_0: Int, _1: Void, _2: Void)]()
            var barHandler: ((Int, Void, Void) -> ())?
            func bar(_ _0: Int, _ _1: Void, _ _2: Void) {
                barCallCount += 1
                barArgValues.append((_0, _1, _2))
                if let barHandler = barHandler {
                    barHandler(_0, _1, _2)
                }

            }
        }
    }
}
