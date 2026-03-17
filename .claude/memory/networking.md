# Networking & External Data

## Current State

The app has **no networking layer** today. All data is local (SwiftData) with automatic CloudKit sync handled by the framework.

### How Data Flows Today

```
User Input → CreateTransactionIntent → ModelContext.insert() → SwiftData (local)
                                                             ↕ CloudKit (automatic)
SwiftData → @Query → View (reactive updates)
```

There are no REST APIs, no custom network clients, and no external data sources.

### CloudKit Sync (Automatic)

- Enabled on device via `cloudKitDatabase: .automatic` in `ModelConfiguration`.
- Disabled in simulator and tests via `cloudKitDatabase: .none`.
- iCloud container: `iCloud.dev.igorcferreira.TransactionHistoryApp`.
- App group: `group.dev.igorcferreira.TransactionHistoryApp`.
- No custom conflict resolution — SwiftData/CloudKit handles merges automatically.

## Future Considerations

As the app grows, networking may be introduced for:

- **Bank API integrations** (fetching real transaction data)
- **Currency exchange rates** (live conversion)
- **Data export/import** (file-based or API-based)
- **Analytics or reporting services**

### Guidelines for When Networking Is Added

Per the project's CLAUDE.md, networking and infrastructure code should be placed in a separate package. When that time comes:

1. Network layer lives in its own Swift Package, not in `TransactionHistory`.
2. The main package depends on the network package for API models and client protocols.
3. Use `async/await` for all network calls — no Combine or completion handlers.
4. Network responses map to local SwiftData models via explicit mapping functions.
5. Error handling follows the `LocalizedError` pattern with user-facing messages.
