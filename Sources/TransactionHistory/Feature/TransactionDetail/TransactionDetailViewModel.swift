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
    var category: EntryCategory

    init(transaction: CardTransaction) {
        self.transaction = transaction
        self.name = transaction.name
        self.merchant = transaction.merchant
        self.card = transaction.card
        self.category = transaction.category
        self.currency = transaction.currency
        self.id = transaction.id
    }

    /// Human-readable date string (e.g. "14 March 2026, 10:30").
    var formattedDate: String {
        transaction.createdAt.formatted(
            .dateTime.day().month(.wide).year().hour().minute()
        )
    }

    /// Localised display name for the currently selected category.
    /// Reflects pending edits while in edit mode.
    var categoryDisplayName: String {
        displayName(for: category)
    }

    /// Ordered list of categories offered to the user in the category picker.
    /// Centralised here so the View never reaches into `EntryCategory.allCases` directly.
    var selectableCategories: [EntryCategory] { EntryCategory.allCases }

    /// Maps an `EntryCategory` to a user-facing localised string.
    /// The View must call this instead of formatting the enum itself.
    func displayName(for category: EntryCategory) -> String {
        .init(localized: .init(stringLiteral: category.rawValue.capitalized))
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
        category = transaction.category
    }

    func save(on modelContext: ModelContext) throws(TransactionDetailError) {
        do {
            try modelContext.transaction {
                transaction.name = name
                transaction.merchant = merchant
                transaction.card = card
                transaction.category = category
                try modelContext.save()
            }
        } catch {
            throw TransactionDetailError.saveFailed
        }
    }

    /// Permanently removes the transaction from the persistent store.
    func delete(on modelContext: ModelContext) throws(TransactionDetailError) {
        do {
            try modelContext.transaction {
                modelContext.delete(transaction)
                try modelContext.save()
            }
        } catch {
            throw TransactionDetailError.deleteFailed
        }
    }
}
