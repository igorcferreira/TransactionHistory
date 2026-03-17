//
//  TransactionDetailViewModel.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import Foundation

@Observable
final class TransactionDetailViewModel {
    let transaction: CardTransaction

    init(transaction: CardTransaction) {
        self.transaction = transaction
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
}
