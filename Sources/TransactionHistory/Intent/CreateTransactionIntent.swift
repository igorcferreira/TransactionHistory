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

    func perform() async throws -> some ReturnsValue<TransactionEntry> {
        guard let mapped = mapper.parse(amount) else {
            throw CreateTransactionError.invalidAmount
        }

        let card = try storage.create(
            name: name,
            currency: mapped.code,
            amount: mapped.value,
            merchant: merchant,
            card: card,
            createdAt: date
        )

        return .result(value: .init(card))
    }
}
