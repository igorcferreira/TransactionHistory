//
//  TransactionDetailViewModelTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import Foundation
import Testing
@testable import TransactionHistory

@Suite("TransactionDetailViewModel")
struct TransactionDetailViewModelTests {

    // MARK: - Helpers

    private static func makeTransaction(
        amount: Double = 12.34,
        currency: String = "EUR",
        createdAt: Date = Date()
    ) -> CardTransaction {
        CardTransaction(
            name: "Test Transaction",
            currency: currency,
            amount: amount,
            merchant: "Test Merchant",
            card: "Test Card",
            createdAt: createdAt
        )
    }

    // MARK: - formattedAmount

    @Test("formattedAmount delegates to the model's formatted currency")
    func formattedAmount() {
        // GIVEN a transaction with a known currency and amount
        let transaction = Self.makeTransaction(amount: 12.34, currency: "EUR")
        let viewModel = TransactionDetailViewModel(transaction: transaction)
        // WHEN accessing formattedAmount
        let result = viewModel.formattedAmount
        // THEN the result matches the model's formattedAmount
        #expect(result == transaction.formattedAmount)
    }

    // MARK: - formattedDate

    @Test("formattedDate includes the year from the transaction date")
    func formattedDateIncludesYear() {
        // GIVEN a transaction with a known date
        let date = Date(timeIntervalSince1970: 0)
        let transaction = Self.makeTransaction(createdAt: date)
        let viewModel = TransactionDetailViewModel(transaction: transaction)
        // WHEN accessing formattedDate
        let result = viewModel.formattedDate
        // THEN the result contains "1970"
        #expect(result.contains("1970"))
    }

    // MARK: - transaction

    @Test("transaction property returns the injected transaction")
    func transactionProperty() {
        // GIVEN a specific transaction
        let transaction = Self.makeTransaction()
        let viewModel = TransactionDetailViewModel(transaction: transaction)
        // WHEN accessing the transaction property
        // THEN it returns the same instance
        #expect(viewModel.transaction.id == transaction.id)
    }
}
