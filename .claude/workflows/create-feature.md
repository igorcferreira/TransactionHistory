# Workflow: Create Feature

End-to-end workflow for adding a new feature domain to the app.

## Inputs

- **Domain name** (e.g., "Budget", "Category", "Report")
- **Core model fields** (what data does this domain store?)
- **Screens needed** (list, detail, create/edit, or a subset)
- **Intent needed?** (should this feature be accessible via Siri/Shortcuts?)
- **Relationships** (does it relate to existing models like CardTransaction?)

## Steps

### 1. Design the Data Model

- [ ] Define the `@Model` class in `Sources/TransactionHistory/Model/`
- [ ] All stored properties have defaults (SwiftData requirement)
- [ ] `id: UUID = UUID()` and `createdAt: Date = Date()`
- [ ] Add computed display properties (e.g., `formattedAmount`)
- [ ] Define relationships with `@Relationship` if connected to existing models
- [ ] Update schema in `DataStorage.createMockEnvironment` to include the new model

### 2. Add Storage Helpers

- [ ] Add fetch/create methods to `DataStorage` (or a new extension)
- [ ] Follow existing patterns: `FetchDescriptor` with sort and optional predicate
- [ ] Use `ModelContext(sharedModelContainer)` — fresh context per operation

### 3. Create the Intent (if needed)

- [ ] Create `[Action][Domain]Intent.swift` in `Sources/TransactionHistory/Intent/`
- [ ] Conform to `AppIntent, Sendable`
- [ ] Accept `ModelContainer` in init for testability
- [ ] Create `[Domain]Entry` AppEntity in `Intent/Model/`
- [ ] Register shortcut phrases in `IntentProvider`
- [ ] Static `execute()` method that calls `intent.callAsFunction(donate: true)`

### 4. Build ViewModels

- [ ] `[Domain]ListViewModel` — search text, sort order state
- [ ] `[Domain]ListGroupViewModel` — `createQuery()`, grouping logic
- [ ] `[Domain]DetailViewModel` — display state for selected item
- [ ] `Create[Domain]ViewModel` — form fields, `canSave` validation, `save(in:)` method
- [ ] All ViewModels: `@Observable`, `@MainActor` where they drive UI

### 5. Build Views

- [ ] `[Domain]ListView` — header + group view, toolbar add button, callbacks
- [ ] `[Domain]ListGroupView` — `@Query`, sections, row components
- [ ] `[Domain]ListHeaderView` — search field + sort picker
- [ ] `Short[Domain]View` — compact row component in `View/`
- [ ] `[Domain]DetailView` — read-only detail layout
- [ ] `Create[Domain]View` — form with cancel/save toolbar, `.disabled(!canSave)`
- [ ] Add `#Preview` blocks with `.includingMocks()` for every view

### 6. Create Coordinator

- [ ] `[Domain]CoordinatorView` — owns `NavigationStack`, wires callbacks
- [ ] `[Domain]CoordinatorViewModel` — `path`, sheet state, navigation methods
- [ ] Integrate into the app's root coordinator (tab or direct)

### 7. Add Seed Data

- [ ] Update `DataStorage.seedMockData(in:)` with sample items for the new model
- [ ] Ensure previews and simulator show meaningful data

### 8. Write Tests

- [ ] ViewModel tests — validation, state, async save (GIVEN-WHEN-THEN)
- [ ] Storage tests — fetch helpers, empty state, limits, sort order
- [ ] Intent tests — creation, persistence, error cases
- [ ] View tests — ViewInspector structural tests
- [ ] Use isolated in-memory containers per test suite

### 9. Verify Definition of Done

- [ ] `xcodebuild test` — iOS package tests pass
- [ ] `swiftlint lint` — zero violations

## Output

A fully functional feature domain following the same architecture as the Transaction feature, with tests, previews, and Siri integration.
