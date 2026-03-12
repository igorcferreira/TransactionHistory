# Transaction History

## 🎯 What is PostPortuguese?

`Transaction History` is a SwiftUI multi-platform (macOS/iOS) 
which allows the user to manage payment transactions.

## 🏗️ Architecture

### Project Structure

```text
TransactionHistory/
├─ Package.swift                       # Swift package configuration
├─ Sources/TransactionHistory/         # Main codebase, holds the data and UI layers
    ├─ Model                           # Data Models (Swift Data)
    ├─ Storage                         # Data layer, responsible for fetch/create/update helpers
    ├─ View                            # UI layer, including View and ViewModel
    ├─ Intent                          # AppIntent layer, to interact with Shortcuts/Siri
├─ Tests/TransactionHistory/           # Test suit for the main codebase
├─ App/TransactionHistoryApp.xcodeproj # Configuration of macOS/iOS app.
├─ App/TransactionHistoryApp/          # macOS/iOS app entrypoint. Mostly empty.
├─ App/TransactionHistoryAppTests/     # Unit test suit for the app.
├─ App/TransactionHistoryAppUITests/   # Interface test suit for the app.
```

### Running tests

The project has a Swift Package AND a SwiftUI app.

Changes are mainly made in the Swift Package.
As consequence, running the app test is only necessary when changing the app's xcodeproj configuration or files.

The Package tests must always be run.

Testing requires the usage of `xcrun swift test` and `xcodebuild test`.

> **Note:** Always use `xcrun swift test` (not plain `swift test`) to ensure the Xcode-bundled
> toolchain is used. The `_SwiftData_SwiftUI` cross-import overlay that provides `@Query` and
> `modelContainer` is only available through the Xcode toolchain, not standalone Swift toolchains.

#### macOS

Testing Packages:

```shell
xcrun swift test -c debug
```

Testing app:

```shell
(cd App ; xcodebuild test -configuration Debug \
    -scheme 'TransactionHistoryApp' \
    -destination 'platform=macOS,arch=arm64,name=My Mac')
```

#### iOS 

Testing package:

```shell
xcodebuild test -configuration Debug \
    -scheme 'TransactionHistory' \
    -destination 'platform=iOS Simulator,OS=latest,arch=arm64,name=iPhone 17'
```

Testing app:

```shell
(cd App ; xcodebuild test -configuration Debug \
    -scheme 'TransactionHistoryApp' \
    -destination 'platform=iOS Simulator,OS=latest,arch=arm64,name=iPhone 17')
```

### SwiftLint

**Always run SwiftLint before declaring any change or feature complete.** Fix every error and warning reported before committing.

```shell
swiftlint lint
```

An initial attempt to automatically fix lint issues can be done by using:

```shell
swiftlint lint --fix
```

SwiftLint also runs automatically as an Xcode build phase on the TransactionHistoryApp target — a successful build with zero warnings confirms the app sources are clean.

**When SwiftLint reports a violation, always fix the code first.** Only propose disabling a rule or raising a threshold after explicitly telling the user what you intend to change and receiving their confirmation. Never silently adjust `.swiftlint.yml`.

### Git lock

**NEVER fight the git lock system.** This means:
- NEVER delete or attempt to remove `.git/index.lock`
- NEVER poll or inspect which process holds the lock
- NEVER retry the same git command in a tight loop

**When a git lock conflict occurs, the one and only correct action is:**
1. Wait a second for the lock to clear: `sleep 1`
2. Then run the git command

**Never run git operations in parallel.** All git commands must be strictly sequential.

## **✅ ALWAYS DO:**

1. **🏆 Follow project structure**
   - Ensure that the project structure is respected
   - Logic related to posting and network infrastructure must be placed on [acaraje](acaraje) package

2. **🎯 Create maintainable code**
   - Include logical comments in the generated code
   - Keep low complexity functions, as much as possible
   - Follow a MVVM+Coordinators architecture for the UI layers and simple clean architecture for the other layers
   - Keep the code simple

3. **📋 MAP quality standards**
   - Minimum Awesome Product always
   - Type-safe code generation
   - Professional error messages
   - Zero compilation errors

## **❌ NEVER DO:**

1. **🚨 Marketing over reality**
   - Real technical status always
   - Document known issues openly
   - Progress metrics must be honest

2. **🚨 Skip compilation testing**
   - Generated code must compile without errors
   - Test both white-label app and Swift Packages

3. **🚨 Custom test frameworks**
   - Give preference to unit tests
   - NO custom matchers or BDD libraries
   - Follow GIVEN-WHEN-THEN standard
