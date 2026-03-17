# iOS Architecture

The project follows **MVVM + Coordinator** with **SwiftData** persistence and **AppIntents** for Siri/Shortcuts. This document defines the architectural rules and patterns.

## Layer Stack

```
┌─────────────────────────────────┐
│         App Entry Point         │  TransactionHistoryApp.swift
│  (ModelContainer + Scene setup) │
├─────────────────────────────────┤
│          Coordinator            │  NavigationStack owner
│   (path, sheets, navigation)    │
├─────────────────────────────────┤
│          Feature View           │  SwiftUI struct, callbacks
│      (no navigation logic)      │
├─────────────────────────────────┤
│          ViewModel              │  @Observable, @MainActor
│    (state, validation, logic)   │
├─────────────────────────────────┤
│       Intent (optional)         │  AppIntent, Sendable
│  (action execution + donation)  │
├─────────────────────────────────┤
│          Storage                │  DataStorage (Sendable struct)
│  (fetch/create/update helpers)  │
├─────────────────────────────────┤
│           Model                 │  @Model (SwiftData)
│   (persistent data + computed)  │
└─────────────────────────────────┘
```

## Coordinator Pattern

### Rules

1. **Only Coordinators own `NavigationStack`.**
2. Feature views receive **callbacks** (`onItemTapped`, `onAddTapped`) — they never push, pop, or present.
3. Coordinator's ViewModel manages navigation state: `path` (NavigationPath), sheet booleans, selected items.
4. Sheets get their own inner `NavigationStack` only when they need a navigation bar (e.g., Create forms with a toolbar).

### Current Implementation

```swift
// TransactionCoordinatorView.swift
NavigationStack(path: $viewModel.path) {
    TransactionListView(
        onTransactionTapped: viewModel.showDetail,
        onAddTapped: viewModel.showCreateTransaction
    )
    .navigationDestination(for: CardTransaction.self) { ... }
    .sheet(isPresented: $viewModel.isAddingTransaction) { ... }
}
```

### Adding a New Feature Domain

When the app grows to multiple domains (e.g., Budgets, Categories), the root coordinator will evolve into a **tab-based coordinator** that hosts domain-specific sub-coordinators:

```
AppCoordinator (TabView)
├── TransactionCoordinator (NavigationStack)
├── BudgetCoordinator (NavigationStack)
└── SettingsCoordinator (NavigationStack)
```

Each sub-coordinator follows the same pattern: owns its NavigationStack, manages its path/sheets.

## Dependency Injection

### ModelContainer (not ModelContext)

- `ModelContainer` is `Sendable` — safe to pass anywhere.
- `ModelContext` is **not** Sendable — create it on the actor that will use it: `ModelContext(container)`.
- The App attaches `ModelContainer` to the scene via `.modelContainer()`.
- Views access `ModelContext` through `@Environment(\.modelContext)`.
- ViewModels/Intents receive `ModelContainer` explicitly when they need data access.

### DataStorage

- `DataStorage` is a `Sendable` struct wrapping `ModelContainer`.
- It provides typed fetch helpers (e.g., `top()`, `with(ids:)`).
- Test initialization: `DataStorage(container: makeInMemoryContainer())`.
- Production initialization: `DataStorage()` uses the shared container.
- As more domains are added, either extend `DataStorage` or create domain-specific storage types.

## Intent Pattern

### Structure

```swift
struct [Action][Domain]Intent: AppIntent, Sendable {
    static let title: LocalizedStringResource = "..."
    private let container: ModelContainer

    // @Parameter declarations...

    func perform() async throws -> some ReturnsValue<EntityType> {
        let result = try create[Domain](/* params */)
        return .result(value: .init(result))
    }
}
```

### Execution Path

All code paths (UI save, Siri, Shortcuts) go through the same static method:

```swift
static func execute(/* params */, container: ModelContainer) async throws {
    var intent = [Intent](container: container)
    intent.param1 = value1
    _ = try await intent.callAsFunction(donate: true)
}
```

This ensures Siri donation happens regardless of entry point.

## Feature File Organization

Each feature domain follows this directory structure:

```
Feature/
└── [Domain]/
    ├── [Domain]CoordinatorView.swift
    ├── [Domain]CoordinatorViewModel.swift
    ├── [Domain]ListView.swift
    ├── [Domain]ListViewModel.swift
    ├── [Domain]DetailView.swift
    ├── [Domain]DetailViewModel.swift
    ├── Create[Domain]View.swift
    ├── Create[Domain]ViewModel.swift
    └── Group/                        (if grouping is needed)
        ├── [Domain]Group.swift
        ├── [Domain]ListGroupView.swift
        └── [Domain]ListGroupViewModel.swift
```

## Data Flow Summary

```
User Action → View → Callback → Coordinator → Navigation Update
                  → ViewModel → Intent.execute() → ModelContext → SwiftData
                                                → Siri Donation
UI Update  ← @Query ← SwiftData change notification
```
