# Transaction History

SwiftUI multi-platform (macOS/iOS) app for managing payment transactions.
MVVM + Coordinator architecture with SwiftData persistence.

> For architecture, patterns, and codebase map see `.claude/` (agents, skills, memory, workflows, index).

## **⚠️ Definition of Done:** A feature or change is only complete when **all three** checks pass:
1. macOS package tests
2. iOS package tests
3. SwiftLint — `swiftlint lint` reports zero violations

Never skip any of these steps.

**When the change touches App-level files** (anything under `App/TransactionHistoryApp/`, `App/TransactionHistoryApp.xcodeproj/`, or asset catalogs), you **must also run the App unit tests** on both platforms, as described in the `Running tests` subsections below.

App-level changes include: app entry point (`TransactionHistoryApp.swift`), `Info.plist`, entitlements, asset catalogs (icons, colors), xcodeproj build settings, and test plans.
These tests are **not optional** — they validate that the app builds and launches correctly on both platforms.

**UI tests (`TransactionHistoryAppUITests`) are expensive** — they launch the full app in light and dark appearance modes. **Do NOT run UI tests as part of routine validation.** Only run them when the user explicitly requests it.

## Running tests

The project has a Swift Package AND a SwiftUI app.

Changes are mainly made in the Swift Package.
As consequence, running the app test is only necessary when changing the app's xcodeproj configuration or files.

The Package tests must always be run.

### macOS

Testing Packages:

```shell
xcrun swift test -c debug
```

> **Note:** Always use `xcrun swift test` (not plain `swift test`) to ensure the Xcode-bundled
> toolchain is used. The `_SwiftData_SwiftUI` cross-import overlay that provides `@Query` and
> `modelContainer` is only available through the Xcode toolchain, not standalone Swift toolchains.

Testing app (unit tests only):

```shell
(cd App ; xcodebuild test -configuration Debug \
    -scheme 'TransactionHistoryApp' \
    -destination 'platform=macOS,arch=arm64,name=My Mac' \
    -only-testing:TransactionHistoryAppTests)
```

Testing app (UI tests — only when explicitly requested):

```shell
(cd App ; xcodebuild test -configuration Debug \
    -scheme 'TransactionHistoryApp' \
    -destination 'platform=macOS,arch=arm64,name=My Mac' \
    -only-testing:TransactionHistoryAppUITests)
```

### iOS

Testing package:

```shell
xcodebuild test -configuration Debug \
    -scheme 'TransactionHistory' \
    -destination 'platform=iOS Simulator,OS=latest,arch=arm64,name=iPhone 17'
```

Testing app (unit tests only):

```shell
(cd App ; xcodebuild test -configuration Debug \
    -scheme 'TransactionHistoryApp' \
    -destination 'platform=iOS Simulator,OS=latest,arch=arm64,name=iPhone 17' \
    -only-testing:TransactionHistoryAppTests)
```

Testing app (UI tests — only when explicitly requested):

```shell
(cd App ; xcodebuild test -configuration Debug \
    -scheme 'TransactionHistoryApp' \
    -destination 'platform=iOS Simulator,OS=latest,arch=arm64,name=iPhone 17' \
    -only-testing:TransactionHistoryAppUITests)
```

### SwiftLint

**Always run SwiftLint in addition to both macOS and iOS package tests before declaring any change or feature complete.** Fix every error and warning reported before committing.

```shell
swiftlint lint
```

An initial attempt to automatically fix lint issues can be done by using:

```shell
swiftlint lint --fix
```

SwiftLint also runs automatically as an Xcode build phase on the TransactionHistoryApp target — a successful build with zero warnings confirms the app sources are clean.

**When SwiftLint reports a violation, always fix the code first.** Only propose disabling a rule or raising a threshold after explicitly telling the user what you intend to change and receiving their confirmation. Never silently adjust `.swiftlint.yml`.

## Git lock

**NEVER fight the git lock system.** This means:
- NEVER delete or attempt to remove `.git/index.lock`
- NEVER poll or inspect which process holds the lock
- NEVER retry the same git command in a tight loop

**When a git lock conflict occurs, the one and only correct action is:**
1. Wait a second for the lock to clear: `sleep 1`
2. Then run the git command

**Never run git operations in parallel.** All git commands must be strictly sequential.

## Knowledge Base

Reference `.claude/` for detailed context:

- **New feature** → `.claude/workflows/create-feature.md`
- **Code review** → `.claude/workflows/review-pr.md`
- **Architecture** → `.claude/skills/ios-architecture.md`
- **Codebase map** → `.claude/index.md`
- **Project patterns** → `.claude/memory/known-patterns.md`

## Rules

- Generated code must compile with zero errors on both platforms
- Follow MVVM + Coordinator architecture (details in `.claude/skills/ios-architecture.md`)
- Keep functions simple and low-complexity
- Include logical comments in generated code
- Use GIVEN-WHEN-THEN for tests — no custom matchers or BDD libraries
- Professional error messages — type-safe, user-facing
- Be honest about technical status — document known issues openly
- Never silently adjust `.swiftlint.yml` — ask the user first
