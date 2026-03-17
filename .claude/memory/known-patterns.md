# Known Patterns

Recurring code patterns in this project. Reference these when building new features to maintain consistency.

## 1. ViewModel Initialization in Views

ViewModels are owned by their View via `@State`:

```swift
@State private var viewModel = TransactionListViewModel()
```

For ViewModels that need initialization parameters:

```swift
@State private var viewModel: TransactionDetailViewModel

init(transaction: CardTransaction) {
    _viewModel = State(initialValue: TransactionDetailViewModel(transaction: transaction))
}
```

**Rule:** Never pass ViewModels between views. Each view creates its own.

## 2. Callback-Based Navigation

Feature views expose optional closures for navigation events:

```swift
var onTransactionTapped: ((CardTransaction) -> Void)?
var onAddTapped: (() -> Void)?
```

The Coordinator wires these to its own navigation methods:

```swift
TransactionListView(
    onTransactionTapped: viewModel.showDetail,
    onAddTapped: viewModel.showCreateTransaction
)
```

## 3. Dynamic @Query Construction

The ViewModel builds the Query, the View applies it in `init`:

```swift
// In GroupViewModel
func createQuery(search: String, sortOrder: SortOrder) -> Query<[CardTransaction], [CardTransaction]> {
    let predicate: Predicate<CardTransaction>
    if search.isEmpty {
        predicate = #Predicate { _ in true }
    } else {
        predicate = #Predicate { $0.merchant.localizedStandardContains(search) }
    }
    return Query(filter: predicate, sort: [SortDescriptor(\.createdAt, order: sortOrder)])
}

// In GroupView init
self._transactions = viewModel.createQuery(search: search, sortOrder: sortOrder)
```

## 4. Date-Based Grouping

Transactions (and potentially future models) are grouped by calendar day:

```swift
// Group items by day
Dictionary(grouping: items) { item in
    Calendar.current.startOfDay(for: item.createdAt)
}
```

Section titles use relative formatting: "Today", "Yesterday", or a formatted date string.

## 5. Intent as Single Execution Path

All data creation goes through the Intent, even from the UI:

```swift
// From ViewModel.save()
try await CreateTransactionIntent.execute(
    name: name, merchant: merchant, amount: amountText,
    card: card, date: date, container: container
)
```

This ensures Siri donation happens for every creation, regardless of entry point.

## 6. In-Memory Container for Tests

Every test suite creates isolated containers:

```swift
private static func makeContainer() throws -> ModelContainer {
    let schema = Schema([CardTransaction.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
    return try ModelContainer(for: schema, configurations: [config])
}
```

**Rule:** Tests never share state. Each test gets a fresh container.

## 7. Currency Parsing (CurrencyMapper)

Amount strings (e.g., "€12.50", "$4.99", "R$100") are parsed via `CurrencyMapper`:

1. Build symbol table from all available Locales (longest symbol first).
2. Match leading symbol against the table.
3. Parse the numeric portion with locale-aware `NumberFormatter`.
4. Fallback chain: explicit symbol → device locale → POSIX → comma-decimal locale.

Returns `CurrencyValue(code: String, value: Double)` or `nil` on failure.

## 8. Preview with Mock Data

All previews use `.includingMocks()` to get an in-memory container with sample data:

```swift
#Preview {
    TransactionListView()
        .includingMocks()
}
```

Named previews for specific states:

```swift
#Preview("With Search") {
    TransactionListGroupView(search: "Coff")
        .includingMocks()
}
```

## 9. Form Validation Pattern

Create/Edit ViewModels expose a computed `canSave` property:

```swift
var canSave: Bool {
    !name.trimmingCharacters(in: .whitespaces).isEmpty
    && !merchant.trimmingCharacters(in: .whitespaces).isEmpty
    && !card.trimmingCharacters(in: .whitespaces).isEmpty
    && (Double(amountText) ?? 0) > 0
}
```

The Save button is `.disabled(!viewModel.canSave)`.

## 10. Coordinator ViewModel Pattern

Coordinator state management:

```swift
@Observable
@MainActor
final class TransactionCoordinatorViewModel {
    var path = NavigationPath()
    var isAddingTransaction = false

    func showDetail(_ transaction: CardTransaction) {
        path.append(transaction)
    }

    func showCreateTransaction() {
        isAddingTransaction = true
    }
}
```

Navigation state (`path`, sheet booleans) lives in the Coordinator's ViewModel, not in feature ViewModels.
