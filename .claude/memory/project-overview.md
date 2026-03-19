# Project Overview

## What Is TransactionHistory?

A SwiftUI iOS app (iOS 26+) for managing payment transactions. Built with SwiftData for persistence and CloudKit for cross-device sync.

## Current State

The app is in its **first vertical slice** — the Transaction domain is functional with full CRUD, search, sort, grouping, and Siri/Shortcuts integration. More feature domains (and data models) are planned.

### What Exists Today

- **One data model:** `CardTransaction` (id, name, currency, amount, merchant, card, createdAt)
- **One feature flow:** Transaction list → detail → create
- **One coordinator:** `TransactionCoordinatorView` (NavigationStack-based)
- **One storage struct:** `DataStorage` with fetch helpers
- **One intent:** `CreateTransactionIntent` for Siri/Shortcuts
- **Currency parsing:** `CurrencyMapper` — locale-aware symbol-to-ISO-code resolver
- **~42 tests** across ViewModel, Storage, Intent, and View layers

### What's Coming

- Additional data models (budgets, categories, etc.)
- Multiple feature flows beyond transactions
- File integration and data analysis features
- The app will grow into a full-featured financial management tool

## Tech Stack

| Component | Technology |
|-----------|-----------|
| UI | SwiftUI (iOS 26+) |
| State | Swift Observation (`@Observable`) |
| Persistence | SwiftData (`@Model`, `@Query`) |
| Sync | CloudKit (automatic, device only) |
| Intents | AppIntents framework |
| Testing | Swift Testing + ViewInspector |
| Linting | SwiftLint |
| Package | Swift Package (6.2 tools) |
| Min platforms | iOS 26 |

## Package Dependencies

| Dependency | Version | Purpose |
|-----------|---------|---------|
| ViewInspector | 0.10.3 | UI structure testing (test target) |
| swift-log | 1.7.0 | Centralized logging (AppLogger) |
| swift-metrics | 2.5.1 | Metrics API (AppMetrics) |
| Scout | 0.1.0 | Production metrics backend |

## Build & Test

The project is a **Swift Package** inside an **Xcode app wrapper**. Most development happens in the package; the app provides the entry point, entitlements, and asset catalog.

Two checks must pass for any change (Definition of Done):
1. `xcodebuild test` on iOS Simulator (iOS package tests)
2. `swiftlint lint` (zero violations)
