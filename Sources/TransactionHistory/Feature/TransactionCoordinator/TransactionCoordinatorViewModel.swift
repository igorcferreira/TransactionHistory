//
//  TransactionCoordinatorViewModel.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import Foundation
import Logging

@Observable
final class TransactionCoordinatorViewModel {
    /// Navigation path tracking which transactions have been pushed.
    var path: [CardTransaction] = []

    /// Whether the "create transaction" sheet is presented.
    var isAddingTransaction: Bool = false

    /// Push the detail screen for a given transaction.
    func showDetail(
        for transaction: CardTransaction,
        logger: Logger = AppLogger.makeLogger(label: "feature.transactionCoordinator")
    ) {
        logger.info(
            "Navigating to transaction detail",
            metadata: [
                "transactionID": "\(transaction.id.uuidString)",
                "merchant": "\(transaction.merchant)",
                "createdAt": "\(transaction.createdAt.ISO8601Format())"
            ]
        )
        path.append(transaction)
    }

    /// Present the create-transaction sheet.
    func showCreateTransaction(
        logger: Logger = AppLogger.makeLogger(label: "feature.transactionCoordinator")
    ) {
        logger.info("Presenting create transaction sheet")
        isAddingTransaction = true
    }

    /// Pop back to the transaction list.
    func popToRoot(
        logger: Logger = AppLogger.makeLogger(label: "feature.transactionCoordinator")
    ) {
        logger.info(
            "Returning to transaction list",
            metadata: ["pathDepth": "\(path.count)"]
        )
        path.removeAll()
    }
}
