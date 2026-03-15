//
//  CreateTransactionIntent.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import Foundation
import AppIntents

struct CreateTransactionIntent: AppIntent, Sendable {
    enum CreateTransactionError: LocalizedError {
        case invalidAmount

        var errorDescription: String? {
            switch self {
            case .invalidAmount:
                return "Invalid amount. The amount must be formatted with a valid currency symbol and value."
            }
        }
    }

    static let title: LocalizedStringResource = "Create Transaction"
    static let supportedModes: IntentModes = .background

    private let mapper = CurrencyMapper()
    private let storage = DataStorage()

    @Parameter(
        title: "Name",
        requestValueDialog: "What is the name of this transaction?"
    )
    var name: String
    @Parameter(
        title: "Merchant",
        requestValueDialog: "Where was this transaction made?"
    )
    var merchant: String
    @Parameter(
        title: "Amount",
        requestValueDialog: "How much was this transaction?"
    )
    var amount: String
    @Parameter(
        title: "Card",
        requestValueDialog: "Which card was used for this transaction?"
    )
    var card: String
    @Parameter(
        title: "Purchase date",
        requestValueDialog: "When was this transaction made?"
    )
    var date: Date

    /// Creates and persists a transaction, then donates the intent to Siri.
    /// In test environments donation is skipped since the AppIntents
    /// runtime is not available in package tests.
    static func execute(
        name: String,
        merchant: String,
        amount: String,
        card: String,
        date: Date
    ) async throws {
        // Persist the transaction using the shared core logic.
        _ = try createTransaction(
            name: name, merchant: merchant,
            amount: amount, card: card, date: date
        )

        // Donate the intent to Siri so it can suggest this action.
        if !ProcessInfo.isTest {
            var intent = CreateTransactionIntent()
            intent.name = name
            intent.merchant = merchant
            intent.amount = amount
            intent.card = card
            intent.date = date
            _ = try await intent.callAsFunction(donate: true)
        }
    }

    func perform() async throws -> some ReturnsValue<TransactionEntry> {
        let card = try Self.createTransaction(
            name: name, merchant: merchant,
            amount: amount, card: card, date: date
        )
        return .result(value: .init(card))
    }

    /// Core persistence logic shared by `execute(...)` and `perform()`.
    private static func createTransaction(
        name: String,
        merchant: String,
        amount: String,
        card: String,
        date: Date
    ) throws -> CardTransaction {
        let mapper = CurrencyMapper()
        guard let mapped = mapper.parse(amount) else {
            throw CreateTransactionError.invalidAmount
        }
        let storage = DataStorage()
        return try storage.create(
            name: name,
            currency: mapped.code,
            amount: mapped.value,
            merchant: merchant,
            card: card,
            createdAt: date
        )
    }
}
