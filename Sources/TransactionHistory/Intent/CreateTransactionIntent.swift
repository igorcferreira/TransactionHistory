//
//  CreateTransactionIntent.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import AppIntents
import Foundation
import SwiftData

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

    /// Default model context from the shared DataStorage container.
    private static var defaultContext: ModelContext { DataStorage().modelContext }

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
    /// - Parameter context: The model context used for persistence.
    ///   Defaults to a context from the shared `DataStorage` container.
    static func execute(
        name: String,
        merchant: String,
        amount: String,
        card: String,
        date: Date,
        context: ModelContext = defaultContext
    ) async throws {
        _ = try createTransaction(
            name: name, merchant: merchant,
            amount: amount, card: card, date: date,
            context: context
        )
        try await donate(
            name: name, merchant: merchant,
            amount: amount, card: card, date: date
        )
    }

    func perform() async throws -> some ReturnsValue<TransactionEntry> {
        let card = try Self.createTransaction(
            name: name, merchant: merchant,
            amount: amount, card: card, date: date
        )
        return .result(value: .init(card))
    }

    /// Persists a transaction in the given model context.
    @discardableResult
    static func createTransaction(
        name: String,
        merchant: String,
        amount: String,
        card: String,
        date: Date,
        context: ModelContext = defaultContext
    ) throws -> CardTransaction {
        let mapper = CurrencyMapper()
        guard let mapped = mapper.parse(amount) else {
            throw CreateTransactionError.invalidAmount
        }
        let transaction = CardTransaction(
            name: name,
            currency: mapped.code,
            amount: mapped.value,
            merchant: merchant,
            card: card,
            createdAt: date
        )
        try context.transaction {
            context.insert(transaction)
            try context.save()
        }
        return transaction
    }

    /// Donates the intent to Siri so it can suggest this action.
    /// In test environments donation is skipped since the AppIntents
    /// runtime is not available in package tests.
    static func donate(
        name: String,
        merchant: String,
        amount: String,
        card: String,
        date: Date
    ) async throws {
        guard !ProcessInfo.isTest else { return }
        var intent = CreateTransactionIntent()
        intent.name = name
        intent.merchant = merchant
        intent.amount = amount
        intent.card = card
        intent.date = date
        _ = try await intent.callAsFunction(donate: true)
    }
}
