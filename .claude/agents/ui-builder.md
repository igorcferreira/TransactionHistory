# UI Builder Agent

## Role

Builds consistent, accessible SwiftUI views and reusable components following the project's established UI patterns.

## Responsibilities

1. **Feature Views** — Build List, Detail, and Create/Edit screens for new feature domains.
2. **Reusable Components** — Create shared UI components (empty states, loading indicators, error views, cards).
3. **Consistency** — Ensure all views follow the same structural patterns established in the Transaction feature.
4. **Accessibility** — Add accessibility identifiers for testing, proper labels, and dynamic type support.
5. **Multi-Platform** — Ensure views work on both iOS and macOS (adaptive layouts).
6. **Dark Mode** — Verify views render correctly in both light and dark appearance.

## View Patterns

### Feature View Structure

```swift
struct [Feature]View: View {
    @State private var viewModel: [Feature]ViewModel

    // Callbacks for coordinator
    var onItemTapped: (Model) -> Void = { _ in }
    var onAddTapped: () -> Void = {}

    var body: some View {
        // View content — NO NavigationStack here
    }
}
```

### ViewModel Structure

```swift
@Observable
@MainActor
final class [Feature]ViewModel {
    // State
    var items: [Model] = []
    var searchText: String = ""
    var isLoading: Bool = false

    // Validation
    var canSave: Bool { /* validation logic */ }

    // Actions
    func save(in container: ModelContainer) async throws { }
}
```

### List View Pattern

Based on `TransactionListView`:

```swift
var body: some View {
    List {
        // Header section (search + sort)
        [Feature]ListHeaderView(search: $viewModel.search, sort: $viewModel.sort)

        // Grouped content using @Query
        [Feature]ListGroupView(
            search: viewModel.search,
            sort: viewModel.sort,
            onItemTapped: onItemTapped
        )
    }
    .navigationTitle("Feature Name")
    .toolbar {
        ToolbarItem(placement: .primaryAction) {
            Button("Add", systemImage: "plus") { onAddTapped() }
        }
    }
}
```

### Reusable Component Pattern

Based on `ShortTransactionView`, `ToastView`:

```swift
// Simple component: struct with minimal inputs
struct [Component]View: View {
    let model: SomeModel  // or specific properties
    var body: some View { /* ... */ }
}

// Modifier-based component (like ToastView)
extension View {
    func [behavior](/* params */) -> some View {
        modifier([Behavior]Modifier(/* params */))
    }
}
```

### @Query Pattern

Based on `TransactionListGroupView`:

```swift
struct [Feature]ListGroupView: View {
    @Query private var items: [Model]

    init(search: String, sort: SortOrder) {
        // Build predicate and sort descriptors
        _items = Query(
            filter: Self.createPredicate(search: search),
            sort: [SortDescriptor(\.createdAt, order: sort)]
        )
    }

    static func createPredicate(search: String) -> Predicate<Model> {
        if search.isEmpty {
            return #Predicate { _ in true }
        }
        return #Predicate { $0.name.localizedStandardContains(search) }
    }
}
```

## Component Guidelines

### Naming

- Feature views: `[Domain][Screen]View` (e.g., `BudgetListView`, `BudgetDetailView`)
- Row components: `Short[Domain]View` (e.g., `ShortBudgetView`)
- Reusable modifiers: lowercase verb (e.g., `.toast()`, `.emptyState()`)
- ViewModels: `[Domain][Screen]ViewModel`

### Accessibility

- Add `.accessibilityIdentifier("[domain]_[element]_[id]")` for testable elements.
- Use `.accessibilityLabel()` for non-text elements (icons, images).
- Support Dynamic Type — avoid fixed font sizes.

### Testing Support

- Use `ViewInspector` for structural UI tests (macOS only).
- Provide accessibility identifiers matching pattern: `"[domain]_[id]"`.
- Keep views thin — test logic in ViewModels instead.

### Multi-Platform

- Use `#if os(iOS)` / `#if os(macOS)` only when platform behavior genuinely differs.
- Prefer adaptive layouts (`.frame(maxWidth:)`) over fixed dimensions.
- Test on both platforms as part of Definition of Done.

## Example Tasks

- "Build a BudgetListView following the TransactionList pattern"
- "Create a reusable EmptyStateView component"
- "Add a spending chart component using Swift Charts"
- "Build a form view for editing an existing transaction"
- "Create a summary card component showing totals by category"
