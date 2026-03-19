# Codebase Index

Quick-reference map of the repository. Use this to locate modules, understand boundaries, and navigate the project.

## Project Root

| Path | Purpose |
|------|---------|
| `Package.swift` | Swift package manifest — targets, dependencies, platform requirements |
| `.swiftlint.yml` | SwiftLint configuration — disabled rules, thresholds |
| `CLAUDE.md` | Project conventions, build/test commands, Definition of Done |
| `README.md` | Project documentation |

## Data Models

| File | Type | Description |
|------|------|-------------|
| `Sources/TransactionHistory/Model/CardTransaction.swift` | `@Model` | Core transaction entity: id, name, currency, amount, merchant, card, createdAt |
| `Sources/TransactionHistory/Model/CurrencyValue.swift` | `struct` | Parsed currency result: code (ISO 4217) + numeric value |
| `Sources/TransactionHistory/Model/CurrencyMapper.swift` | `struct` | Locale-aware parser: currency string → CurrencyValue |

## Storage Layer

| File | Type | Description |
|------|------|-------------|
| `Sources/TransactionHistory/Storage/DataStorage.swift` | `struct` (Sendable) | Wraps ModelContainer, provides fetch helpers (`top()`, `with(ids:)`), manages container lifecycle, seeds mock data |

## Support / Infrastructure

| File | Type | Description |
|------|------|-------------|
| `Sources/TransactionHistory/Support/AppLogger.swift` | `enum` (Sendable) | Centralized logging bootstrap, namespaced `Logger` factory, SwiftUI environment key |
| `Sources/TransactionHistory/Support/AppMetrics.swift` | `enum` (Sendable) | Centralized metrics bootstrap, namespaced `Counter`/`Timer`/`Gauge` factory (swift-metrics); Scout as production backend |

## Feature Modules

### Transaction Coordinator

| File | Type | Description |
|------|------|-------------|
| `Sources/TransactionHistory/Feature/TransactionCoordinator/TransactionCoordinatorView.swift` | View | Root NavigationStack, wires navigation destinations and sheets |
| `Sources/TransactionHistory/Feature/TransactionCoordinator/TransactionCoordinatorViewModel.swift` | ViewModel | Navigation state: `path`, `isAddingTransaction`, `showDetail()`, `showCreateTransaction()` |

### Transaction List

| File | Type | Description |
|------|------|-------------|
| `Sources/TransactionHistory/Feature/TransactionList/TransactionListView.swift` | View | Main list screen: header + grouped content, toolbar add button, callbacks |
| `Sources/TransactionHistory/Feature/TransactionList/TransactionListViewModel.swift` | ViewModel | Search text + sort order state |
| `Sources/TransactionHistory/Feature/TransactionList/TransactionListHeaderView.swift` | View | Search field + sort picker (segmented control) |
| `Sources/TransactionHistory/Feature/TransactionList/Group/TransactionListGroupView.swift` | View | @Query-driven list with date-based sections |
| `Sources/TransactionHistory/Feature/TransactionList/Group/TransactionListGroupViewModel.swift` | ViewModel | Builds @Query descriptors, groups by date, formats section titles |
| `Sources/TransactionHistory/Feature/TransactionList/Group/TransactionGroup.swift` | Model | Grouping struct: date + array of transactions |

### Transaction Detail

| File | Type | Description |
|------|------|-------------|
| `Sources/TransactionHistory/Feature/TransactionDetail/TransactionDetailView.swift` | View | Read-only detail display for a selected transaction |
| `Sources/TransactionHistory/Feature/TransactionDetail/TransactionDetailViewModel.swift` | ViewModel | Display state for a single transaction |

### Create Transaction

| File | Type | Description |
|------|------|-------------|
| `Sources/TransactionHistory/Feature/CreateTransaction/CreateTransactionView.swift` | View | Form with cancel/save toolbar, validation-gated save |
| `Sources/TransactionHistory/Feature/CreateTransaction/CreateTransactionViewModel.swift` | ViewModel | Form fields, `canSave` validation, `save(in:)` delegates to Intent |

## Intent Layer (Siri / Shortcuts)

| File | Type | Description |
|------|------|-------------|
| `Sources/TransactionHistory/Intent/CreateTransactionIntent.swift` | AppIntent | Creates transactions, parses currency, donates to Siri |
| `Sources/TransactionHistory/Intent/IntentProvider.swift` | AppShortcutsProvider | Registers shortcut phrases ("Register a purchase", "Log a transaction") |
| `Sources/TransactionHistory/Intent/Model/TransactionEntry.swift` | AppEntity | Wraps CardTransaction for Shortcuts display |
| `Sources/TransactionHistory/Intent/Model/EntryCategory.swift` | Enum | Transaction category for intent classification |

## Reusable Views

| File | Type | Description |
|------|------|-------------|
| `Sources/TransactionHistory/View/ShortTransactionView.swift` | View | Compact row: name, merchant, amount, time |
| `Sources/TransactionHistory/View/ToastView.swift` | ViewModifier | Auto-dismissing notification overlay (`.toast(message:)`) |
| `Sources/TransactionHistory/View/Iterate.swift` | View | Enumerated ForEach helper with stable IDs |

## App Target

| File | Type | Description |
|------|------|-------------|
| `App/TransactionHistoryApp/TransactionHistoryApp.swift` | @main | App entry point: creates DataStorage, attaches ModelContainer, registers shortcuts |
| `App/TransactionHistoryApp/Info.plist` | Config | App metadata |
| `App/TransactionHistoryApp/TransactionHistoryApp.entitlements` | Config | CloudKit, app groups, file protection |
| `App/TransactionHistoryApp/Assets.xcassets/` | Assets | App icon, accent color |
| `App/TransactionHistoryApp.xcodeproj/` | Project | Xcode build configuration, schemes, test plans |

## Tests

### Package Tests

| File | Covers |
|------|--------|
| `Tests/TransactionHistoryTests/DataStorageTests.swift` | `DataStorage.top()`, `with(ids:)` — empty, limits, sort, filtering |
| `Tests/TransactionHistoryTests/CreateTransactionViewModelTests.swift` | `canSave` validation (12 tests), `save()` persistence |
| `Tests/TransactionHistoryTests/CreateTransactionIntentTests.swift` | Intent creation, currency parsing, error cases |
| `Tests/TransactionHistoryTests/CurrencyMapperTests.swift` | Symbol parsing, fallbacks, locale handling |
| `Tests/TransactionHistoryTests/TransactionCoordinatorViewModelTests.swift` | Navigation state: path, sheet toggles |
| `Tests/TransactionHistoryTests/TransactionDetailViewModelTests.swift` | Detail display state |
| `Tests/TransactionHistoryTests/TransactionListViewTests.swift` | ViewInspector: search, sort, structure |
| `Tests/TransactionHistoryTests/TransactionListViewSortTests.swift` | ViewInspector: sort order behavior |
| `Tests/TransactionHistoryTests/AppLoggerTests.swift` | AppLogger defaults and handler configuration |
| `Tests/TransactionHistoryTests/AppMetricsTests.swift` | AppMetrics bootstrap idempotency, factory methods |
| `Tests/TransactionHistoryTests/TransactionHistoryTests.swift` | Base test file |

### App Tests

| File | Covers |
|------|--------|
| `App/TransactionHistoryAppTests/` | App-level unit tests (placeholder) |
| `App/TransactionHistoryAppUITests/` | Full UI tests — light/dark mode (expensive, run only when requested) |

## Data Flow Map

```
User Action
    │
    ▼
Feature View ──callback──▶ Coordinator ──▶ Navigation (push/sheet)
    │
    ▼
ViewModel ──▶ Intent.execute() ──▶ ModelContext ──▶ SwiftData
                                        │
                                        ▼
                                   CloudKit (device only)
    ▲
    │
@Query ◀── SwiftData change notification ──── automatic UI update
```

## Where to Add New Things

| Adding... | Location |
|-----------|----------|
| New data model | `Sources/TransactionHistory/Model/` |
| New fetch/create helpers | `Sources/TransactionHistory/Storage/DataStorage.swift` (extension) |
| New feature screens | `Sources/TransactionHistory/Feature/[DomainName]/` |
| New Siri action | `Sources/TransactionHistory/Intent/` |
| New reusable component | `Sources/TransactionHistory/View/` |
| New logging / metrics support | `Sources/TransactionHistory/Support/` |
| New package tests | `Tests/TransactionHistoryTests/` |
| App-level changes | `App/TransactionHistoryApp/` |
