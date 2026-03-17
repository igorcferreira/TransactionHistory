# UI Components

Patterns for building SwiftUI views and reusable components in this project.

## View Patterns

### Feature View (List)

The standard list view delegates navigation via callbacks and composes a header + grouped content:

```swift
public struct [Domain]ListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = [Domain]ListViewModel()

    var onItemTapped: (([Model]) -> Void)?
    var onAddTapped: (() -> Void)?

    public var body: some View {
        VStack(spacing: 0) {
            [Domain]ListHeaderView(
                searchText: $viewModel.searchText,
                sortOrder: $viewModel.sortOrder
            )
            [Domain]ListGroupView(
                search: viewModel.searchText,
                sortOrder: viewModel.sortOrder,
                onItemTapped: onItemTapped
            )
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { onAddTapped?() } label: {
                    Label("Add [Domain]", systemImage: "plus")
                }
            }
        }
    }
}
```

Key points:
- `@State private var viewModel` — owned by the view.
- Callbacks are optional closures with defaults.
- No `NavigationStack` — that's the coordinator's job.
- Header and grouped content are separate sub-views.

### Feature View (Detail)

```swift
struct [Domain]DetailView: View {
    @State private var viewModel: [Domain]DetailViewModel

    init(item: [Model]) {
        _viewModel = State(initialValue: [Domain]DetailViewModel(item: item))
    }

    var body: some View {
        // Read-only detail layout
    }
}
```

### Feature View (Create/Edit Form)

```swift
struct Create[Domain]View: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = Create[Domain]ViewModel()

    var body: some View {
        Form {
            // Form fields bound to viewModel properties
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        try await viewModel.save(in: modelContext.container)
                        dismiss()
                    }
                }
                .disabled(!viewModel.canSave)
            }
        }
    }
}
```

### @Query Group View

For views that display grouped, filtered, sorted data from SwiftData:

```swift
struct [Domain]ListGroupView: View {
    @Query private var items: [Model]
    private let sortOrder: SortOrder
    private let viewModel: [Domain]ListGroupViewModel

    var onItemTapped: (([Model]) -> Void)?

    init(search: String = "", sortOrder: SortOrder = .reverse, ...) {
        let viewModel = [Domain]ListGroupViewModel()
        self._items = viewModel.createQuery(search: search, sortOrder: sortOrder)
        self.sortOrder = sortOrder
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            ForEach(groups) { group in
                Section {
                    Iterate(group.items.enumerated()) { item in
                        Button { onItemTapped?(item) } label: {
                            Short[Domain]View(item: item)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text(viewModel.sectionTitle(for: group.date))
                        .font(.headline)
                        .textCase(.uppercase)
                }
            }
        }
        .listStyle(.plain)
    }
}
```

Key points:
- `@Query` is initialized in `init` from ViewModel's `createQuery()`.
- Grouping logic lives in the ViewModel, not the View.
- `Iterate` helper used for enumerated ForEach with stable IDs.

## Reusable Components

### Row Component (ShortView)

Compact representation of a model for use in lists:

```swift
struct Short[Domain]View: View {
    let item: [Model]

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name).font(.body).bold()
                Text(item.subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(item.formattedValue).font(.body)
                Text(item.formattedDate).font(.caption).foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("[domain]_\(item.id)")
    }
}
```

### View Modifier Component (Toast Pattern)

For behaviors that can be applied to any view:

```swift
extension View {
    func toast(message: Binding<String?>) -> some View {
        modifier(ToastModifier(message: message))
    }
}

private struct ToastModifier: ViewModifier {
    @Binding var message: String?

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottom) {
            if let message {
                // Toast UI with auto-dismiss
            }
        }
    }
}
```

### Preview Pattern

All views provide `#Preview` blocks using `.includingMocks()`:

```swift
#Preview {
    [Domain]ListView()
        .includingMocks()
}

#Preview("With Search") {
    [Domain]ListGroupView(search: "Coffee")
        .includingMocks()
}
```

The `.includingMocks()` modifier attaches an in-memory ModelContainer with seeded data.

## Accessibility

- Row components: `.accessibilityIdentifier("[domain]_\(id)")`.
- Sections: `.id("section_\(group.id)")` and `.id("section_\(group.id)_header")`.
- List containers: `.id("[domain]_list")`.
- Follow this pattern for all new components to enable ViewInspector and UI testing.

## Multi-Platform Notes

- Use adaptive layouts — avoid fixed dimensions.
- The same views run on iOS and macOS; use `#if os()` only when genuinely needed.
- Test previews on both platforms.
