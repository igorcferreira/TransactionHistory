//
//  TransactionDetailViewModelTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import Foundation
import SwiftData
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
            category: .generic,
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

    // MARK: - revert

    @Test("revert restores name to original value after mutation")
    func revertRestoresName() {
        // GIVEN a view model whose name has been changed
        let transaction = Self.makeTransaction()
        let viewModel = TransactionDetailViewModel(transaction: transaction)
        viewModel.name = "Changed Name"
        // WHEN reverting
        viewModel.revert()
        // THEN the name matches the original transaction
        #expect(viewModel.name == "Test Transaction")
    }

    @Test("revert restores merchant to original value after mutation")
    func revertRestoresMerchant() {
        // GIVEN a view model whose merchant has been changed
        let transaction = Self.makeTransaction()
        let viewModel = TransactionDetailViewModel(transaction: transaction)
        viewModel.merchant = "Changed Merchant"
        // WHEN reverting
        viewModel.revert()
        // THEN the merchant matches the original transaction
        #expect(viewModel.merchant == "Test Merchant")
    }

    @Test("revert restores card to original value after mutation")
    func revertRestoresCard() {
        // GIVEN a view model whose card has been changed
        let transaction = Self.makeTransaction()
        let viewModel = TransactionDetailViewModel(transaction: transaction)
        viewModel.card = "Changed Card"
        // WHEN reverting
        viewModel.revert()
        // THEN the card matches the original transaction
        #expect(viewModel.card == "Test Card")
    }

    @Test("revert restores all editable fields after multiple mutations")
    func revertRestoresAllFields() {
        // GIVEN a view model with all editable fields changed
        let transaction = Self.makeTransaction()
        let viewModel = TransactionDetailViewModel(transaction: transaction)
        viewModel.name = "New Name"
        viewModel.merchant = "New Merchant"
        viewModel.card = "New Card"
        // WHEN reverting
        viewModel.revert()
        // THEN all fields match the original transaction
        #expect(viewModel.name == "Test Transaction")
        #expect(viewModel.merchant == "Test Merchant")
        #expect(viewModel.card == "Test Card")
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

    // MARK: - delete

    /// Creates an in-memory ModelContainer for delete tests.
    private static func makeContainer() throws -> ModelContainer {
        let schema = Schema([CardTransaction.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [config])
    }

    @Test("delete removes the transaction from the model context")
    func deleteRemovesTransaction() throws {
        // GIVEN a transaction inserted into an in-memory context
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        let transaction = Self.makeTransaction()
        context.insert(transaction)
        try context.save()

        let viewModel = TransactionDetailViewModel(transaction: transaction)

        // WHEN deleting the transaction
        try viewModel.delete(on: context)

        // THEN fetching all transactions returns an empty result
        let descriptor = FetchDescriptor<CardTransaction>()
        let remaining = try context.fetch(descriptor)
        #expect(remaining.isEmpty)
    }

    @Test("delete persists the removal across contexts")
    func deletePersistsRemoval() throws {
        // GIVEN a transaction inserted and saved via one context
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        let transaction = Self.makeTransaction()
        context.insert(transaction)
        try context.save()

        let viewModel = TransactionDetailViewModel(transaction: transaction)

        // WHEN deleting the transaction
        try viewModel.delete(on: context)

        // THEN a fresh context on the same container also returns empty
        let freshContext = ModelContext(container)
        let descriptor = FetchDescriptor<CardTransaction>()
        let remaining = try freshContext.fetch(descriptor)
        #expect(remaining.isEmpty)
    }
}
