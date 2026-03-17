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
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    init() {
        self.container = DataStorage().sharedModelContainer
    }

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
        default: nil,
        requestValueDialog: "When was this transaction made?"
    )
    var date: Date?
    @Parameter(
        title: "Category",
        default: nil,
        requestValueDialog: "What is the category of the purchase?"
    )
    var category: EntryCategory?

    func perform() async throws -> some ReturnsValue<TransactionEntry> {
        let card = try createTransaction(
            name: name, merchant: merchant,
            amount: amount, card: card, category: category ?? .generic,
            date: date
        )
        return .result(value: .init(card))
    }

    /// Persists a transaction in the given model context.
    func createTransaction(
        name: String,
        merchant: String,
        amount: String,
        card: String,
        category: EntryCategory,
        date: Date?
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
            category: category,
            createdAt: date ?? Date()
        )
        let ctx = ModelContext(container)
        try ctx.transaction {
            ctx.insert(transaction)
            try ctx.save()
        }
        return transaction
    }

    /// Donates the intent to Siri so it can suggest this action.
    /// In test environments donation is skipped since the AppIntents
    /// runtime is not available in package tests.
    static func execute(
        name: String,
        merchant: String,
        amount: String,
        card: String,
        category: EntryCategory? = nil,
        date: Date? = nil,
        container: ModelContainer = DataStorage().sharedModelContainer
    ) async throws {
        var intent = CreateTransactionIntent(container: container)
        intent.name = name
        intent.merchant = merchant
        intent.amount = amount
        intent.card = card
        intent.date = date
        intent.category = category
        _ = try await intent.callAsFunction(donate: true)
    }
}
