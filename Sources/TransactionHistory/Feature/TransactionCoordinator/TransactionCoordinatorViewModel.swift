//
//  TransactionCoordinatorViewModel.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import Foundation

@Observable
final class TransactionCoordinatorViewModel {
    /// Navigation path tracking which transactions have been pushed.
    var path: [CardTransaction] = []

    /// Whether the "create transaction" sheet is presented.
    var isAddingTransaction: Bool = false

    /// Push the detail screen for a given transaction.
    func showDetail(for transaction: CardTransaction) {
        path.append(transaction)
    }

    /// Present the create-transaction sheet.
    func showCreateTransaction() {
        isAddingTransaction = true
    }

    /// Pop back to the transaction list.
    func popToRoot() {
        path.removeAll()
    }
}
