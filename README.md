# ![](Images/logo.png)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/2964/badge)](https://bestpractices.coreinfrastructure.org/projects/2964)
[![Build Status](https://github.com/uber/mockolo/actions/workflows/builds.yml/badge.svg?branch=master)](https://github.com/uber/mockolo/actions/workflows/builds.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![FOSSA Status](https://app.fossa.com/api/projects/custom%2B4458%2Fgithub.com%2Fuber%2Fmockolo.svg?type=shield)](https://app.fossa.com/projects/custom%2B4458%2Fgithub.com%2Fuber%2Fmockolo?ref=badge_shield)

# Welcome to Mockolo

**Mockolo** is an efficient mock generator for Swift. Swift doesn't provide mocking support, and Mockolo provides a fast and easy way to autogenerate mock objects that can be tested in your code. One of the main objectives of Mockolo is fast performance.  Unlike other frameworks, Mockolo provides highly performant and scalable generation of mocks via a lightweight commandline tool, so it can  run as part of a linter or a build if one chooses to do so. Try Mockolo and enhance your project's test coverage in an effective, performant way.


## Motivation
One of the main objectives of this project is high performance.  There aren't many 3rd party tools that perform fast on a large codebase containing, for example, over 2M LoC or over 10K protocols.  They take several hours and even with caching enabled take several minutes.  Mockolo was built to make highly performant generation of mocks possible (in the magnitude of seconds) on such large codebase. It uses a minimal set of frameworks necessary (mentioned in the Used libraries section) to keep the code lean and efficient.

Another objective is to enable flexibility in using or overriding types if needed. This allows use of some of the features that require deeper analysis such as protocols with associated types to be simpler, more straightforward, and less fragile.


## Disclaimer
This project may contain unstable APIs which may not be ready for general use. Support and/or new releases may be limited.


## System Requirements

* Swift 5.10 or later
* Xcode 15.3 or later
* macOS 13.0 or later and Linux
* Support is included for the Swift Package Manager


## Build / Install

Option 1: By [Mint](https://github.com/yonaskolb/Mint)

```
$ mint install uber/mockolo
$ mint run uber/mockolo mockolo -h // see commandline input options below
```

Option 2: [Homebrew](https://brew.sh/)

```
$ brew install mockolo
```

Option 3: Use as Build Tools Plugin with [Swift Package Manager](https://swift.org/package-manager/)

Add binaryTarget and plugin definition to your `Package.swift`.
Binary url and checksum can be found in the [releases](https://github.com/uber/mockolo/releases) page.

```swift
targets: [
    ...
    .plugin(
        name: "RunMockolo",
        capability: .buildTool(),
        dependencies: [.target(name: "mockolo")]
    ),
    .binaryTarget(
        name: "mockolo",
        url: "...",
        checksum: "..."
    ),
```

Implement the plugin and specify necessary directories in the arguments.

- `Plugins/RunMockolo/RunMockoloPlugin.swift`

```swift
import PackagePlugin

@main struct RunMockoloPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        let generatedSourcePath = context.pluginWorkDirectory.appending("GeneratedMocks.swift")
        let packageRoot = context.package.directory

        return [
            .prebuildCommand(
                displayName: "Run mockolo",
                executable: try context.tool(named: "mockolo").path,
                arguments: [
                    "-s", packageRoot.appending("Sources", "MyModule").string,
                    "-d", generatedSourcePath,
                ],
                outputFilesDirectory: context.pluginWorkDirectory
            ),
        ]
    }
}
```

Finally, add the plugin to the target requiring mockolo.

```swift
.target(
    name: "MyTarget",
    dependencies: [
        ...
    ],
    plugins: [
        .plugin(name: "RunMockolo"),
    ]
),
```

Option 4: Use the binary

  Go to the Release tab and download/install the binary directly.

Option 5: Clone and build/run

```
$ git clone https://github.com/uber/mockolo.git
$ cd mockolo
$ swift build -c release
$ .build/release/mockolo -h  // see commandline input options below
```

To call mockolo from any location, copy the executable into a directory that is part of your `PATH` environment variable.

## Run

`Mockolo` is a commandline executable. To run it, pass in a list of the source file directories or file paths of a build target, and the destination filepath for the mock output. To see other arguments to the commandline, run `mockolo --help`.

```
./mockolo -s myDir -d ./OutputMocks.swift -x Images Strings
```

This parses all the source files in `myDir` directory, excluding any files ending with `Images` or `Strings` in the file name (e.g. MyImages.swift), and generates mocks to a file at `OutputMocks.swift` in the current directory.

Use --help to see the complete argument options.

```
./mockolo -h  // or --help

OVERVIEW: Mockolo: Swift mock generator.

USAGE: mockolo [<options>] --destination <destination>

OPTIONS:
  --allow-set-call-count  If set, generated *CallCount vars will be allowed to set manually.
  --annotation <annotation>
                          A custom annotation string used to indicate if a type should be mocked (default = @mockable). (default: @mockable)
  -j, --concurrency-limit <n>
                          Maximum number of threads to execute concurrently (default = number of cores on the running machine).
  --custom-imports <custom-imports>
                          If set, custom module imports (separated by a space) will be added to the final import statement list.
  --enable-args-history   Whether to enable args history for all functions (default = false). To enable history per function, use the 'history' keyword in the annotation argument.
  --disable-combine-default-values
                          Whether to disable generating Combine streams in mocks (default = false). Set this to true to control how your streams are created in your mocks.
  --exclude-imports <exclude-imports>
                          If set, listed modules (separated by a space) will be excluded from the import statements in the mock output.
  -x, --exclude-suffixes <exclude-suffixes>
                          List of filename suffix(es) without the file extensions to exclude from parsing (separated by a space).
  --header <header>       A custom header documentation to be added to the beginning of a generated mock file.
  -l, --logging-level <n> The logging level to use. Default is set to 0 (info only). Set 1 for verbose, 2 for warning, and 3 for error. (default: 0)
  --macro <macro>         If set, #if [macro] / #endif will be added to the generated mock file content to guard compilation.
  --mock-all              If set, it will mock all types (protocols and classes) with a mock annotation (default is set to false and only mocks protocols with a mock annotation).
  --mock-filelist <mock-filelist>
                          Path to a file containing a list of dependent files (separated by a new line) of modules this target depends on.
  --mock-final            If set, generated mock classes will have the 'final' attributes (default is set to false).
  -mocks, --mockfiles <mocks>
                          List of mock files (separated by a space) from modules this target depends on. If the --mock-filelist value exists, this will be ignored.
  -d, --destination <destination>
                          Output file path containing the generated Swift mock classes. If no value is given, the program will exit.
  -s, --sourcedirs <sourcedirs>
                          Paths to the directories containing source files to generate mocks for (separated by a space). If the --filelist or --sourcefiles values exist, they will be ignored.
  -f, --filelist <filelist>
                          Path to a file containing a list of source file paths (delimited by a new line). If the --sourcedirs value exists, this will be ignored.
  -srcs, --sourcefiles <srcs>
                          List of source files (separated by a space) to generate mocks for. If the --sourcedirs or --filelist value exists, this will be ignored.
  -i, --testable-imports <testable-imports>
                          If set, @testable import statements will be added for each module name in this list (separated by a space).
  --use-template-func     If set, a common template function will be called from all functions in mock classes (default is set to false).
  -h, --help              Show help information.
```


## Distribution

The `install-script.sh` will build and package up the `mockolo` binary and other necessary resources in the same bundle.

```sh
$ ./install-script.sh -h  // see input options
$ ./install-script.sh -s [source dir] -t mockolo -d [destination dir] -o [output filename].tar.gz
```

This will create a tarball for distribution, which contains the `mockolo` executable.



## How to use

For example, Foo.swift contains:

```swift
/// @mockable
public protocol Foo {
    var num: Int { get set }
    func bar(arg: Float) -> String
}
```

Running ```./mockolo -srcs Foo.swift -d ./OutputMocks.swift ``` will output:

```swift
public class FooMock: Foo {
    init() {}
    init(num: Int = 0) {
        self.num = num
    }

    var numSetCallCount = 0
    var underlyingNum: Int = 0
    var num: Int {
        get {
            return underlyingNum
        }
        set {
            underlyingNum = newValue
            numSetCallCount += 1
        }
    }

    var barCallCount = 0
    var barHandler: ((Float) -> String)?
    func bar(arg: Float) -> String {
        barCallCount += 1
        if let barHandler = barHandler {
            return barHandler(arg)
        }
        return ""
    }
}
```

The above mock can now be used in a test as follows:

```swift
func testMock() {
    let mock = FooMock(num: 5)
    XCTAssertEqual(mock.numSetCallCount, 1)
    mock.barHandler = { arg in
        return String(arg)
    }
    XCTAssertEqual(mock.barCallCount, 1)
}
```

## Arguments

A list of override arguments can be passed in (delimited by a semicolon) to the annotation to set var types, typealiases, module names, etc.


### Module

```swift
/// @mockable(module: prefix = Bar)
public protocol Foo {
    ...
}
```

This will generate:

```swift
public class FooMock: Bar.Foo {
    ...
}
```

### Typealias

```swift
/// @mockable(typealias: T = AnyObject; U = StringProtocol)
public protocol Foo {
    associatedtype T
    associatedtype U: Collection where U.Element == T
    associatedtype W
    ...
}
```

This will generate the following mock output:

```swift
public class FooMock: Foo {
    typealias T = AnyObject // overridden
    typealias U = StringProtocol // overridden
    typealias W = Any // default placeholder type for typealias
    ...
}
```


### RxSwift

For a var type such as an RxSwift observable:

```swift
/// @mockable(rx: intStream = ReplaySubject; doubleStream = BehaviorSubject)
public protocol Foo {
    var intStream: Observable<Int> { get }
    var doubleStream: Observable<Double> { get }
}
```

This will generate:

```swift
public class FooMock: Foo {
    var intStreamSubject = ReplaySubject<Int>.create(bufferSize: 1)
    var intStream: Observable<Int> { /* use intStreamSubject */ }
    var doubleStreamSubject = BehaviorSubject<Int>(value: 0)
    var doubleStream: Observable<Int> { /* use doubleStreamSubject */ }
}
```

### Function Argument History

To capture function arguments history:

```swift
/// @mockable(history: fooFunc = true)
public protocol Foo {
    func fooFunc(val: Int)
    func barFunc(_ val: (a: String, Float))
    func bazFunc(val1: Int, val2: String)
}
```

This will generate:

```swift
public class FooMock: Foo {
    var fooFuncCallCount = 0
    var fooFuncArgValues = [Int]() // arguments captor
    var fooFuncHandler: ((Int) -> ())?
    func fooFunc(val: Int) {
        fooFuncCallCount += 1
        fooFuncArgValues.append(val)   // capture arguments

        if fooFuncHandler = fooFuncHandler {
            fooFuncHandler(val)
        }
    }

    ...
    var barFuncArgValues = [(a: String, Float)]() // tuple is also supported.
    ...

    ...
    var bazFuncArgValues = [(Int, String)]()
    ...
}
```

and also, enable the arguments captor for all functions if you passed `--enable-args-history` arg to `mockolo` command.
> NOTE: The arguments captor only supports singular types (e.g. variable, tuple). The closure variable is not supported.

### Combine's AnyPublisher

To generate mocks for Combine's AnyPublisher:

```swift
/// @mockable(combine: fooPublisher = PassthroughSubject; barPublisher = CurrentValueSubject)
public protocol Foo {
    var fooPublisher: AnyPublisher<String, Never> { get }
    var barPublisher: AnyPublisher<Int, CustomError> { get }
}
```

This will generate:

```swift
public class FooMock: Foo {
    public init() { }

    public var fooPublisher: AnyPublisher<String, Never> { return self.fooPublisherSubject.eraseToAnyPublisher() }
    public private(set) var fooPublisherSubject = PassthroughSubject<String, Never>()

    public var barPublisher: AnyPublisher<Int, CustomError> { return self.barPublisherSubject.eraseToAnyPublisher() }
    public private(set) var barPublisherSubject = CurrentValueSubject<Int, CustomError>(0)
}
```

You can also connect an AnyPublisher to a property within the protocol.

For example:
```swift
/// @mockable(combine: fooPublisher = @Published foo)
public protocol Foo {
    var foo: String { get }
    var fooPublisher: AnyPublisher<String, Never> { get }
}
```

This will generate:
```swift
public class FooMock: Foo {
    public init() { }
    public init(foo: String = "") {
        self.foo = foo
    }

    public private(set) var fooSetCallCount = 0
    @Published public var foo: String = "" { didSet { fooSetCallCount += 1 } }

    public var fooPublisher: AnyPublisher<String, Never> { return self.$foo.setFailureType(to: Never.self).eraseToAnyPublisher() }
}
```

### Overrides

To override the generated mock name:
```swift
/// @mockable(override: name = FooMock)
public protocol FooProtocol { ... }
```

This will generate:
```swift
public class FooMock: FooProtocol { ... }
```

## How to contribute to Mockolo
See [CONTRIBUTING](CONTRIBUTING.md) for more info.


## Report any issues

If you run into any problems, please file a git issue. Please include:

* The OS version (e.g. macOS 10.14.6)
* The Swift version installed on your machine (from `swift --version`)
* The Xcode version
* The specific release version of this source code (you can use `git tag` to get a list of all the release versions or `git log` to get a specific commit sha)
* Any local changes on your machine



## License

Mockolo is licensed under Apache License 2.0. See [LICENSE](LICENSE.txt) for more information.

    Copyright (C) 2017 Uber Technologies

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

