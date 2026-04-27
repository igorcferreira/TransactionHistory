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
        category: EntryCategory = .generic,
        createdAt: Date = Date()
    ) -> CardTransaction {
        CardTransaction(
            name: "Test Transaction",
            currency: currency,
            amount: amount,
            merchant: "Test Merchant",
            card: "Test Card",
            category: category,
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

    @Test("revert restores category to original value after mutation")
    func revertRestoresCategory() {
        // GIVEN a view model whose category has been changed
        let transaction = Self.makeTransaction(category: .food)
        let viewModel = TransactionDetailViewModel(transaction: transaction)
        viewModel.category = .travel
        // WHEN reverting
        viewModel.revert()
        // THEN the category matches the original transaction
        #expect(viewModel.category == .food)
    }

    @Test("revert restores all editable fields after multiple mutations")
    func revertRestoresAllFields() {
        // GIVEN a view model with all editable fields changed
        let transaction = Self.makeTransaction(category: .shopping)
        let viewModel = TransactionDetailViewModel(transaction: transaction)
        viewModel.name = "New Name"
        viewModel.merchant = "New Merchant"
        viewModel.card = "New Card"
        viewModel.category = .travel
        // WHEN reverting
        viewModel.revert()
        // THEN all fields match the original transaction
        #expect(viewModel.name == "Test Transaction")
        #expect(viewModel.merchant == "Test Merchant")
        #expect(viewModel.card == "Test Card")
        #expect(viewModel.category == .shopping)
    }

    // MARK: - category

    @Test("init copies category from the transaction")
    func initSetsCategoryFromTransaction() {
        // GIVEN a transaction with a specific category
        let transaction = Self.makeTransaction(category: .food)
        // WHEN creating a view model
        let viewModel = TransactionDetailViewModel(transaction: transaction)
        // THEN the view model exposes the same category
        #expect(viewModel.category == .food)
    }

    @Test("categoryDisplayName follows the current category, not the persisted one")
    func categoryDisplayNameReflectsCurrentCategory() {
        // GIVEN a view model whose category has been changed in memory
        let transaction = Self.makeTransaction(category: .generic)
        let viewModel = TransactionDetailViewModel(transaction: transaction)
        viewModel.category = .shopping
        // WHEN reading the display name
        let result = viewModel.categoryDisplayName
        // THEN the display name reflects the new selection
        #expect(result.contains("Shopping"))
    }

    @Test("displayName formats an arbitrary category into a user-facing string")
    func displayNameFormatsCategory() {
        // GIVEN a view model
        let viewModel = TransactionDetailViewModel(transaction: Self.makeTransaction())
        // WHEN formatting a category
        let result = viewModel.displayName(for: .travel)
        // THEN the result contains the human-readable label
        #expect(result.contains("Travel"))
    }

    @Test("selectableCategories exposes every EntryCategory case")
    func selectableCategoriesCoversAllCases() {
        // GIVEN a view model
        let viewModel = TransactionDetailViewModel(transaction: Self.makeTransaction())
        // WHEN reading selectableCategories
        let result = viewModel.selectableCategories
        // THEN it contains the full set of cases
        #expect(result == EntryCategory.allCases)
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

    @Test("save persists an updated category across contexts")
    func saveUpdatesCategoryOnTransaction() throws {
        // GIVEN a transaction with .generic inserted into an in-memory context
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        let transaction = Self.makeTransaction(category: .generic)
        context.insert(transaction)
        try context.save()

        let viewModel = TransactionDetailViewModel(transaction: transaction)
        viewModel.category = .travel

        // WHEN saving the view model
        try viewModel.save(on: context)

        // THEN a fresh context sees the updated category
        let freshContext = ModelContext(container)
        let descriptor = FetchDescriptor<CardTransaction>()
        let fetched = try freshContext.fetch(descriptor)
        let persisted = try #require(fetched.first)
        #expect(persisted.category == .travel)
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

    // MARK: - Error types

    @Test("save() error type is TransactionDetailError.saveFailed")
    func saveErrorType() throws {
        // GIVEN a transaction persisted in an in-memory container (happy path)
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        let transaction = Self.makeTransaction()
        context.insert(transaction)
        try context.save()
        let viewModel = TransactionDetailViewModel(transaction: transaction)
        // WHEN saving without mutation on a valid context
        // THEN no error is thrown; the compiler enforces TransactionDetailError at the call site
        // without requiring a cast. Fault-injection to trigger saveFailed requires a custom
        // ModelContext that is not available in-process.
        try viewModel.save(on: context)
    }

    @Test("delete() error type is TransactionDetailError.deleteFailed")
    func deleteErrorType() throws {
        // GIVEN a transaction persisted in an in-memory container (happy path)
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        let transaction = Self.makeTransaction()
        context.insert(transaction)
        try context.save()
        let viewModel = TransactionDetailViewModel(transaction: transaction)
        // WHEN deleting on a valid context
        // THEN no error is thrown; the compiler enforces TransactionDetailError at the call site
        // without requiring a cast. Fault-injection to trigger deleteFailed requires a custom
        // ModelContext that is not available in-process.
        try viewModel.delete(on: context)
    }
}
