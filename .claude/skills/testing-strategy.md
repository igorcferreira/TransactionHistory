# Testing Strategy

Testing patterns, conventions, and infrastructure used in this project.

## Framework

- **Swift Testing** (`@Test`, `@Suite`, `#expect`, `#require`) — not XCTest.
- **ViewInspector** for structural UI tests (macOS only).
- Tests live in `Tests/TransactionHistoryTests/`.

## Test Structure

### GIVEN-WHEN-THEN

Every test follows this format with explicit comments:

```swift
@Test("description of what is being tested")
func testName() throws {
    // GIVEN a specific setup
    let storage = try Self.makeStorage()

    // WHEN an action is performed
    let result = try storage.top()

    // THEN the expected outcome is verified
    #expect(result.isEmpty)
}
```

Rules:
- `@Test("...")` annotation with human-readable description.
- GIVEN, WHEN, THEN comments on separate lines.
- One logical assertion per test (multiple `#expect` calls are fine if they verify the same outcome).

### @Suite Grouping

Tests are grouped into suites by the type they test:

```swift
@Suite("DataStorage")
struct DataStorageTests {
    // MARK: - Helpers
    // MARK: - top()
    // MARK: - with(ids:)
}
```

Use `MARK` comments to organize test sections within a suite.

### @MainActor for ViewModel Tests

ViewModel tests that interact with `@MainActor`-confined types:

```swift
@Suite("CreateTransactionViewModel")
@MainActor
struct CreateTransactionViewModelTests {
    // Tests can directly access @MainActor properties
}
```

## Test Helpers

### In-Memory Container

Every test suite creates isolated containers — never share state between tests:

```swift
private static func makeContainer() throws -> ModelContainer {
    let schema = Schema([CardTransaction.self])
    let config = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: true,
        cloudKitDatabase: .none
    )
    return try ModelContainer(for: schema, configurations: [config])
}
```

### Seeding Test Data

Use a static `seed` helper that returns the created items for assertion:

```swift
@discardableResult
private static func seed(_ count: Int, in storage: DataStorage) throws -> [CardTransaction] {
    let context = storage.modelContext
    var items: [CardTransaction] = []
    for index in 0..<count {
        let item = CardTransaction(
            name: "Transaction \(index)",
            currency: "EUR",
            amount: Double(index) + 1.0,
            merchant: "Merchant",
            card: "Card",
            createdAt: Date(timeIntervalSince1970: TimeInterval(index * 60))
        )
        context.insert(item)
        items.append(item)
    }
    try context.save()
    return items
}
```

Key points:
- `@discardableResult` for flexibility.
- Sequential timestamps for predictable sort order.
- Returns inserted items so tests can reference their IDs.

### Factory Methods

Pre-filled valid objects for testing validation:

```swift
private static func makeValidViewModel() -> CreateTransactionViewModel {
    let viewModel = CreateTransactionViewModel()
    viewModel.name = "Coffee"
    viewModel.merchant = "Coffee Corner"
    viewModel.amountText = "4.50"
    viewModel.currency = "EUR"
    viewModel.card = "Card 1"
    return viewModel
}
```

Then individual tests modify one field to test its validation.

## What to Test

### ViewModel Tests

- **Validation logic** — every `canSave` / `isValid` condition.
- **State transitions** — property changes, computed property derivation.
- **Async operations** — `save()`, `load()`, error cases.
- Test both valid and invalid states.

### Storage Tests

- **Empty state** — returns empty array, not nil or crash.
- **Below limit** — returns all items when fewer than fetch limit.
- **At/above limit** — respects fetch limits.
- **Sort order** — results are ordered as expected.
- **Filtering** — predicate matches and non-matches.

### Intent Tests

- **Successful creation** — item is persisted with correct values.
- **Parse errors** — invalid input throws expected error.
- **Edge cases** — nil optional parameters, boundary values.

### View Tests (ViewInspector)

- **Structure verification** — expected subviews exist.
- **Search behavior** — filtering affects visible items.
- **Sort behavior** — order changes with sort toggle.
- **Section grouping** — items grouped by expected criteria.

Note: ViewInspector tests run on macOS only (`NSHostingController`).

## Running Tests

### Definition of Done — All 3 Must Pass

```shell
# 1. macOS package tests
xcrun swift test -c debug

# 2. iOS package tests
xcodebuild test -configuration Debug \
    -scheme 'TransactionHistory' \
    -destination 'platform=iOS Simulator,OS=latest,arch=arm64,name=iPhone 17'

# 3. SwiftLint
swiftlint lint
```

### App Tests (Only When Changing App-Level Files)

```shell
# macOS app unit tests
(cd App ; xcodebuild test -configuration Debug \
    -scheme 'TransactionHistoryApp' \
    -destination 'platform=macOS,arch=arm64,name=My Mac' \
    -only-testing:TransactionHistoryAppTests)

# iOS app unit tests
(cd App ; xcodebuild test -configuration Debug \
    -scheme 'TransactionHistoryApp' \
    -destination 'platform=iOS Simulator,OS=latest,arch=arm64,name=iPhone 17' \
    -only-testing:TransactionHistoryAppTests)
```

UI tests are expensive — only run when explicitly requested.

## Patterns to Avoid

- **Custom test frameworks** or BDD libraries.
- **Mocking databases** — always use in-memory SwiftData containers.
- **Shared mutable state** between tests.
- **Testing implementation details** — test behavior and outcomes, not internal method calls.
- **XCTest** — use Swift Testing (`@Test`) for all new tests.
