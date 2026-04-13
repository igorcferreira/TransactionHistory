//
//  TransactionDetailViewModel.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import Foundation
import SwiftData

@Observable
final class TransactionDetailViewModel {
    private(set) var transaction: CardTransaction

    let id: UUID
    let currency: String

    var name: String
    var merchant: String
    var card: String

    init(transaction: CardTransaction) {
        self.transaction = transaction
        self.name = transaction.name
        self.merchant = transaction.merchant
        self.card = transaction.card
        self.currency = transaction.currency
        self.id = transaction.id
    }

    /// Human-readable date string (e.g. "14 March 2026, 10:30").
    var formattedDate: String {
        transaction.createdAt.formatted(
            .dateTime.day().month(.wide).year().hour().minute()
        )
    }

    /// Formatted Category Name
    var category: String {
        .init(localized: .init(stringLiteral: transaction.category.rawValue.capitalized))
    }

    /// Locale-formatted currency string delegated to the model.
    var formattedAmount: String {
        transaction.formattedAmount
    }

    /// Restores editable fields to their last-persisted values.
    func revert() {
        name = transaction.name
        merchant = transaction.merchant
        card = transaction.card
    }

    func save(on modelContext: ModelContext) throws {
        try modelContext.transaction {
            transaction.name = name
            transaction.merchant = merchant
            transaction.card = card
            try modelContext.save()
        }
    }

    /// Permanently removes the transaction from the persistent store.
    func delete(on modelContext: ModelContext) throws {
        try modelContext.transaction {
            modelContext.delete(transaction)
            try modelContext.save()
        }
    }
}
