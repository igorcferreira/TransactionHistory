# Data Layer

Patterns for SwiftData models, storage, queries, and persistence in this project.

## SwiftData Models

### Model Declaration

```swift
@Model
public final class [Domain]: Identifiable {
    public var id: UUID = UUID()
    // Stored properties with defaults for SwiftData compatibility
    public var name: String = ""
    public var createdAt: Date = Date()

    // Computed properties for display formatting
    var formattedValue: String { /* ... */ }

    init(id: UUID = UUID(), name: String, /* ... */, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        // ...
        self.createdAt = createdAt
    }
}
```

Rules:
- All stored properties have **defaults** (SwiftData requires this for schema evolution).
- `id` is `UUID`, set with a default of `UUID()`.
- `createdAt` defaults to `Date()`.
- Computed properties handle formatting — Views don't compute display strings.
- Models are `public final class` to allow access from the App target.

### Relationships (Future)

When adding relationships between models:

```swift
@Model
public final class Category: Identifiable {
    public var id: UUID = UUID()
    public var name: String = ""

    @Relationship(deleteRule: .nullify, inverse: \CardTransaction.category)
    public var transactions: [CardTransaction] = []
}
```

- Always specify `deleteRule` explicitly.
- Use `inverse` to keep relationships bidirectional.
- Default relationship collections to `[]`.

## DataStorage

### Structure

`DataStorage` is a `Sendable` struct that owns the `ModelContainer` and provides typed fetch helpers:

```swift
public struct DataStorage: Sendable {
    var modelContext: ModelContext {
        ModelContext(sharedModelContainer)  // Fresh context each time
    }
    public let sharedModelContainer: ModelContainer

    public init() { /* shared production container */ }
    init(container: ModelContainer) { /* test injection */ }
}
```

Key design decisions:
- **Fresh `ModelContext` per access** — avoids stale state and threading issues.
- **`ModelContainer` is Sendable** — safe to store and pass.
- **`ModelContext` is NOT Sendable** — never store or pass across actors.

### Adding Fetch Helpers

As the app grows, add domain-specific methods to `DataStorage`:

```swift
// Grouped by domain using extensions
extension DataStorage {
    func topTransactions() throws -> [CardTransaction] { /* ... */ }
    func transactions(with ids: [UUID]) throws -> [CardTransaction] { /* ... */ }
}

extension DataStorage {
    func allBudgets() throws -> [Budget] { /* ... */ }
    func activeBudget() throws -> Budget? { /* ... */ }
}
```

### FetchDescriptor Patterns

```swift
// Fetch with limit and sort
var descriptor = FetchDescriptor<CardTransaction>(
    sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
)
descriptor.fetchLimit = 10
return try modelContext.fetch(descriptor)

// Fetch with predicate
try modelContext.fetch(FetchDescriptor<CardTransaction>(
    predicate: #Predicate { item in ids.contains(item.id) }
))
```

## @Query in Views

### Dynamic Query Building

The ViewModel builds the `Query` descriptor, and the View initializes `@Query` in `init`:

```swift
// ViewModel
func createQuery(search: String, sortOrder: SortOrder) -> Query<[Model], [Model]> {
    let predicate: Predicate<Model>
    if search.isEmpty {
        predicate = #Predicate { _ in true }
    } else {
        predicate = #Predicate { $0.merchant.localizedStandardContains(search) }
    }
    let sort = [SortDescriptor(\Model.createdAt, order: sortOrder)]
    return Query(filter: predicate, sort: sort)
}

// View init
self._items = viewModel.createQuery(search: search, sortOrder: sortOrder)
```

### Predicate Patterns

```swift
// All items (no filter)
#Predicate<Model> { _ in true }

// Text search (case-insensitive, locale-aware)
#Predicate<Model> { $0.field.localizedStandardContains(searchText) }

// ID-based lookup
#Predicate<Model> { item in ids.contains(item.id) }
```

## Container Configuration

### Production (Device)

```swift
ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false,
    groupContainer: .identifier("group.dev.igorcferreira.TransactionHistoryApp"),
    cloudKitDatabase: .automatic
)
```

### Test / Simulator

```swift
ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: true,
    cloudKitDatabase: .none
)
```

### Test Helper Pattern

Every test suite that needs SwiftData creates its own isolated container:

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

## Data Mutation

### Via Intent (Preferred Path)

All data creation goes through an `AppIntent` so Siri donation happens automatically:

```swift
let ctx = ModelContext(container)
try ctx.transaction {
    ctx.insert(newItem)
    try ctx.save()
}
```

### Seed Data (Development)

Mock data is seeded in `DataStorage.seedMockData(in:)` for simulator/test environments. This runs once during container creation.

## Schema Evolution

When adding new models to the schema, update `DataStorage.createMockEnvironment`:

```swift
let schema = Schema([
    CardTransaction.self,
    Budget.self,        // New model
    Category.self       // New model
])
```

SwiftData handles lightweight migrations automatically. For complex migrations, define `SchemaMigrationPlan`.
