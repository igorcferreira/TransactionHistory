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

    /// Push the detail screen for a given transaction.
    func showDetail(for transaction: CardTransaction) {
        path.append(transaction)
    }

    /// Pop back to the transaction list.
    func popToRoot() {
        path.removeAll()
    }
}
