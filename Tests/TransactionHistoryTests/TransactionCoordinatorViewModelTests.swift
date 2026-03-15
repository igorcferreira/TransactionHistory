//
//  TransactionCoordinatorViewModelTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import Foundation
import Testing
@testable import TransactionHistory

@Suite("TransactionCoordinatorViewModel")
struct TransactionCoordinatorViewModelTests {

    // MARK: - Helpers

    private static func makeTransaction() -> CardTransaction {
        CardTransaction(
            name: "Test",
            currency: "EUR",
            amount: 1.0,
            merchant: "Merchant",
            card: "Card"
        )
    }

    // MARK: - Initial state

    @Test("path is empty on init")
    func initialPathIsEmpty() {
        // GIVEN a new coordinator view model
        let viewModel = TransactionCoordinatorViewModel()
        // THEN the navigation path is empty
        #expect(viewModel.path.isEmpty)
    }

    // MARK: - showDetail

    @Test("showDetail appends a transaction to the path")
    func showDetailAppendsToPath() {
        // GIVEN an empty coordinator
        let viewModel = TransactionCoordinatorViewModel()
        let transaction = Self.makeTransaction()
        // WHEN showing detail for a transaction
        viewModel.showDetail(for: transaction)
        // THEN the path contains one element
        #expect(viewModel.path.count == 1)
    }

    // MARK: - showCreateTransaction

    @Test("isAddingTransaction is false on init")
    func initialIsAddingTransactionIsFalse() {
        // GIVEN a new coordinator view model
        let viewModel = TransactionCoordinatorViewModel()
        // THEN isAddingTransaction is false
        #expect(!viewModel.isAddingTransaction)
    }

    @Test("showCreateTransaction sets isAddingTransaction to true")
    func showCreateTransactionSetsFlag() {
        // GIVEN an empty coordinator
        let viewModel = TransactionCoordinatorViewModel()
        // WHEN showing the create transaction sheet
        viewModel.showCreateTransaction()
        // THEN isAddingTransaction is true
        #expect(viewModel.isAddingTransaction)
    }

    // MARK: - popToRoot

    @Test("popToRoot clears the navigation path")
    func popToRootClearsPath() {
        // GIVEN a coordinator with one transaction in the path
        let viewModel = TransactionCoordinatorViewModel()
        viewModel.showDetail(for: Self.makeTransaction())
        // WHEN popping to root
        viewModel.popToRoot()
        // THEN the path is empty
        #expect(viewModel.path.isEmpty)
    }
}
