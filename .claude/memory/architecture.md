# Architecture

## Pattern: MVVM + Coordinator

### Layer Responsibilities

| Layer | Responsibility | Example |
|-------|---------------|---------|
| **Model** | Persistent data + computed display properties | `CardTransaction` |
| **Storage** | Typed fetch/create helpers wrapping ModelContainer | `DataStorage` |
| **Intent** | Action execution + Siri donation | `CreateTransactionIntent` |
| **ViewModel** | UI state, validation, business logic | `TransactionListViewModel` |
| **View** | Layout, user interaction, callbacks | `TransactionListView` |
| **Coordinator** | NavigationStack, path/sheet management | `TransactionCoordinatorView` |

### Key Architectural Decisions

1. **NavigationStack lives only in Coordinators.** Feature views receive callbacks (`onTransactionTapped`, `onAddTapped`) and never push, pop, or present themselves.

2. **ModelContainer for DI, not ModelContext.** `ModelContainer` is Sendable and safe to pass anywhere. `ModelContext` is created fresh where needed: `ModelContext(container)`.

3. **Single execution path through Intent.** Both UI saves and Siri invocations go through `intent.callAsFunction(donate: true)`, ensuring donation always happens.

4. **@Observable over ObservableObject.** Modern Swift Observation is used everywhere — no Combine, no `@Published`.

5. **@Query for reactive data.** Views use `@Query` with dynamically built predicates and sort descriptors. The ViewModel builds the query; the View initializes it in `init`.

6. **DataStorage is a Sendable struct.** It wraps the shared `ModelContainer` and provides domain-specific fetch methods. Tests inject in-memory containers.

### Navigation Flow

```
TransactionCoordinatorView (NavigationStack)
├── TransactionListView
│   ├── onTransactionTapped → coordinator pushes DetailView
│   └── onAddTapped → coordinator presents CreateView sheet
├── TransactionDetailView (navigationDestination)
└── CreateTransactionView (sheet with inner NavigationStack for toolbar)
```

### Future Evolution

As more domains are added, the architecture will evolve to:

```
AppCoordinator (TabView)
├── TransactionCoordinator (NavigationStack)
├── [NewDomain]Coordinator (NavigationStack)
└── SettingsCoordinator (NavigationStack)
```

Each domain follows the same Coordinator → View → ViewModel → Intent → Storage → Model pattern.

### Directory → Layer Mapping

```
Sources/TransactionHistory/
├── Model/       → @Model entities (SwiftData)
├── Storage/     → DataStorage struct, fetch/create helpers
├── Intent/      → AppIntent implementations, AppEntity wrappers
├── Feature/     → Screen-level Views + ViewModels, organized by domain
│   ├── TransactionCoordinator/
│   ├── TransactionList/
│   ├── TransactionDetail/
│   └── CreateTransaction/
└── View/        → Reusable UI components (cross-domain)
```
