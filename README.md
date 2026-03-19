# Transaction History

`Transaction History` is a SwiftUI iOS app
which allows the user to manage payment transactions.

With the AppIntents exposed by the app, the user is able to register and list transactions,
using Shortcuts/Siri.

Through Shortcuts automation, Wallet events can be used to register transactions as they happen.

## Project structure

```text
TransactionHistory/
├─ Package.swift                       # Swift package configuration
├─ Sources/TransactionHistory/         # Main codebase, holds the data and UI layers
    ├─ Model                           # Data Models (Swift Data)
    ├─ Storage                         # Data layer, responsible for fetch/create/update helpers
    ├─ Feature                         # UI layer, for the app features, including View and ViewModel
    ├─ View                            # Re-usable views
    ├─ Intent                          # AppIntent layer, to interact with Shortcuts/Siri
├─ Tests/TransactionHistory/           # Test suit for the main codebase
├─ App/TransactionHistoryApp.xcodeproj # Configuration of the iOS app.
├─ App/TransactionHistoryApp/          # iOS app entrypoint. Mostly empty.
├─ App/TransactionHistoryAppTests/     # Unit test suit for the app.
├─ App/TransactionHistoryAppUITests/   # Interface test suit for the app.
```

## Shortcut Automation Data

Wallet automation can provide the following data:

- Name: The name of the transaction (computed by the OS)
- Merchant: The name of the merchant where the transaction was made (as registered by Apple)
- Ammount: The transaction ammount, with currency symbol. Example: $12.34
- Card or Pass: The name of the card or pass used in the transaction (as registered in the Wallet)

## iCloud Storage

Swift Data uses iCloud Storage, storing data in the user-bound cloud DB,
under the `iCloud.dev.igorcferreira.TransactionHistoryApp` container.
