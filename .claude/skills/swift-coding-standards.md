# Swift Coding Standards

Conventions and coding style used throughout this project. All new code must follow these standards.

## Language Version & Concurrency

- **Swift 6.2** with strict concurrency checking.
- All types that cross actor/thread boundaries must be `Sendable`.
- Use `async/await` for asynchronous work — no completion handlers or Combine publishers.
- Use `@MainActor` on ViewModels and any type that drives UI state.

## Naming Conventions

### Types

- Models: `[Domain]` noun (e.g., `CardTransaction`, `Budget`, `Category`)
- ViewModels: `[Domain][Screen]ViewModel` (e.g., `TransactionListViewModel`)
- Views: `[Domain][Screen]View` (e.g., `TransactionListView`)
- Coordinators: `[Domain]CoordinatorView` / `[Domain]CoordinatorViewModel`
- Storage: `DataStorage` (single shared struct, extended per domain)
- Intents: `[Action][Domain]Intent` (e.g., `CreateTransactionIntent`)
- Row components: `Short[Domain]View` (e.g., `ShortTransactionView`)

### Properties & Methods

- Boolean properties: `is` / `has` / `can` prefix (e.g., `canSave`, `isAddingTransaction`)
- Callbacks: `on[Event]` (e.g., `onTransactionTapped`, `onAddTapped`)
- Factory methods: `make[Thing]()` (e.g., `makeContainer()`, `makeStorage()`)
- Fetch methods: descriptive verbs (e.g., `top()`, `with(ids:)`)

### Files

- One primary type per file.
- File name matches the primary type (e.g., `CardTransaction.swift`).
- Extensions for protocol conformance can go in the same file if small, or a separate `[Type]+[Protocol].swift` file.

## Access Control

- `public` — Types and initializers exposed to the App target.
- `internal` (default) — Most ViewModels, Views, helpers within the package.
- `private` — Implementation details, helper methods, computed properties not needed externally.
- Prefer the most restrictive access level that works.

## Code Style

### Structure Order

Within a type, organize members in this order:

1. Stored properties
2. Computed properties
3. Initializers
4. Body (for Views)
5. Public methods
6. Private methods

### Comments

- Include comments where the **intent** isn't obvious from the code.
- Use `///` doc comments on public API and non-trivial methods.
- Don't add comments that merely restate the code.

### Error Handling

- Define errors as nested `enum` conforming to `LocalizedError` (e.g., `CreateTransactionError`).
- Provide user-facing `errorDescription` for every case.
- Use `throws` for recoverable errors; `fatalError` only for truly unrecoverable configuration issues.

### SwiftLint

- Zero violations required before merge.
- Run `swiftlint lint --fix` first for auto-fixable issues.
- Custom thresholds: type body 320/500, file length 450/1000.
- `trailing_comma` rule is disabled.
- Never disable a rule without user confirmation.

## Patterns to Avoid

- Force unwraps (`!`) without justification.
- Combine for state management (use `@Observable` instead).
- `ObservableObject` / `@Published` (use `@Observable` / direct properties).
- Singletons for data access (use DI with `ModelContainer`).
- Implicit `self` captures in escaping closures.
- `Any` or `AnyObject` when a protocol or generic would be clearer.
