# Workflow: Build UI Component

Process for creating new SwiftUI views and reusable components.

## Inputs

- **Component type** — feature view (list/detail/create) or reusable component
- **Domain** — which feature domain this belongs to (or "shared" for reusable)
- **Requirements** — what it should display, what interactions it supports
- **Data source** — @Query, ViewModel property, or passed-in model

## Steps

### 1. Determine Component Type

| Type | Location | Naming |
|------|----------|--------|
| Feature list view | `Feature/[Domain]/` | `[Domain]ListView` |
| Feature detail view | `Feature/[Domain]/` | `[Domain]DetailView` |
| Feature create/edit | `Feature/[Domain]/` | `Create[Domain]View` |
| Group view (@Query) | `Feature/[Domain]/Group/` | `[Domain]ListGroupView` |
| Row component | `View/` | `Short[Domain]View` |
| Reusable modifier | `View/` | `[Behavior]View` + `.behavior()` extension |
| Shared utility view | `View/` | Descriptive name |

### 2. Create the ViewModel (if needed)

Feature views need a ViewModel; simple reusable components typically don't.

- [ ] Create `[Component]ViewModel` as `@Observable` class
- [ ] Add `@MainActor` if it drives UI state
- [ ] Define state properties (search, sort, form fields)
- [ ] Add computed properties for validation (`canSave`) or derived state
- [ ] Add action methods (`save(in:)`, `load()`)

### 3. Build the View

- [ ] Follow the correct pattern for the component type (see ui-components skill)
- [ ] Feature views: callbacks for navigation, NO NavigationStack
- [ ] @Query views: build query in `init` from ViewModel
- [ ] Form views: `@Environment(\.dismiss)`, `.disabled(!viewModel.canSave)`
- [ ] Reusable components: minimal inputs, no ViewModel dependency

### 4. Add Accessibility

- [ ] `.accessibilityIdentifier("[domain]_[element]_\(id)")` on interactive elements
- [ ] `.accessibilityLabel()` on non-text elements (icons, images)
- [ ] Verify Dynamic Type works (no fixed font sizes)
- [ ] Test with VoiceOver mentally — does the reading order make sense?

### 5. Add Previews

- [ ] Default preview with `.includingMocks()`
- [ ] Named previews for important states:
  - Empty state
  - Loaded state with data
  - Search/filter active
  - Error state (if applicable)

```swift
#Preview { ComponentView().includingMocks() }
#Preview("Empty") { ComponentView(items: []).includingMocks() }
#Preview("Searching") { ComponentView(search: "query").includingMocks() }
```

### 6. Wire into Coordinator

If this is a feature view:

- [ ] Add navigation destination or sheet in the relevant Coordinator
- [ ] Wire callbacks from the view to Coordinator's ViewModel methods
- [ ] Test the navigation flow manually in preview or simulator

### 7. Write Tests

- [ ] ViewModel tests — validation, state transitions, async operations
- [ ] ViewInspector tests — structural verification, search/sort behavior
- [ ] Follow GIVEN-WHEN-THEN with `@Test`

### 8. Verify

- [ ] Preview renders correctly on iOS
- [ ] Dark mode appearance is acceptable
- [ ] `xcodebuild test` — iOS
- [ ] `swiftlint lint` — zero violations

## Quick Reference: View Skeleton

```swift
struct [Domain][Screen]View: View {
    @State private var viewModel = [Domain][Screen]ViewModel()

    var onItemTapped: (([Model]) -> Void)?

    var body: some View {
        // Content — no NavigationStack
    }
}

#Preview {
    [Domain][Screen]View()
        .includingMocks()
}
```
