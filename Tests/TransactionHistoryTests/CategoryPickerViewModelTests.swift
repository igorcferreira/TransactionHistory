//
//  CategoryPickerViewModelTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 09/05/2026.
//

import Foundation
import SwiftData
import Testing
@testable import TransactionHistory

@Suite("CategoryPickerViewModel")
struct CategoryPickerViewModelTests {

    // MARK: - Helpers

    private static func makeContainer() throws -> ModelContainer {
        let schema = Schema([CardTransaction.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [config])
    }

    private static func makeTransaction(
        id: UUID = UUID(),
        category: EntryCategory = .generic
    ) -> CardTransaction {
        CardTransaction(
            id: id,
            name: "Test Transaction",
            currency: "EUR",
            amount: 42.00,
            merchant: "Test Merchant",
            card: "Test Card",
            category: category
        )
    }

    // MARK: - loadTransaction

    @Test("loadTransaction fetches the transaction by ID")
    @MainActor
    func loadTransactionFetchesByID() throws {
        // GIVEN a transaction persisted in an in-memory container
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        let transaction = Self.makeTransaction()
        context.insert(transaction)
        try context.save()

        let viewModel = CategoryPickerViewModel(
            transactionID: transaction.id,
            container: container
        )

        // WHEN loading the transaction
        viewModel.loadTransaction()

        // THEN the transaction is available
        #expect(viewModel.transaction != nil)
        #expect(viewModel.transaction?.id == transaction.id)
    }

    @Test("loadTransaction sets nil for unknown ID")
    @MainActor
    func loadTransactionReturnsNilForUnknownID() throws {
        // GIVEN an empty container
        let container = try Self.makeContainer()
        let viewModel = CategoryPickerViewModel(
            transactionID: UUID(),
            container: container
        )

        // WHEN loading a non-existent transaction
        viewModel.loadTransaction()

        // THEN transaction is nil
        #expect(viewModel.transaction == nil)
    }

    // MARK: - setCategory

    @Test("setCategory persists the new category")
    @MainActor
    func setCategoryPersists() throws {
        // GIVEN a transaction with .generic category
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        let transaction = Self.makeTransaction(category: .generic)
        context.insert(transaction)
        try context.save()

        let viewModel = CategoryPickerViewModel(
            transactionID: transaction.id,
            container: container
        )
        viewModel.loadTransaction()

        // WHEN setting the category to .food
        viewModel.setCategory(.food)

        // THEN the change is persisted
        let freshContext = ModelContext(container)
        let id = transaction.id
        var descriptor = FetchDescriptor<CardTransaction>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        let fetched = try freshContext.fetch(descriptor).first
        #expect(fetched?.category == .food)
    }

    // MARK: - transactionName

    @Test("transactionName returns the transaction name when available")
    @MainActor
    func transactionNameReturnsName() throws {
        // GIVEN a transaction with a name
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        let transaction = Self.makeTransaction()
        context.insert(transaction)
        try context.save()

        let viewModel = CategoryPickerViewModel(
            transactionID: transaction.id,
            container: container
        )
        viewModel.loadTransaction()

        // THEN transactionName returns the name
        #expect(viewModel.transactionName == "Test Transaction")
    }

    @Test("transactionName returns empty string when transaction is nil")
    @MainActor
    func transactionNameReturnsEmptyWhenNil() throws {
        // GIVEN no transaction loaded
        let container = try Self.makeContainer()
        let viewModel = CategoryPickerViewModel(
            transactionID: UUID(),
            container: container
        )

        // THEN transactionName is empty
        #expect(viewModel.transactionName.isEmpty)
    }

    // MARK: - selectableCategories

    @Test("selectableCategories exposes every EntryCategory case")
    @MainActor
    func selectableCategoriesCoversAllCases() throws {
        // GIVEN a view model
        let container = try Self.makeContainer()
        let viewModel = CategoryPickerViewModel(
            transactionID: UUID(),
            container: container
        )
        // THEN selectableCategories matches EntryCategory.allCases
        #expect(viewModel.selectableCategories == EntryCategory.allCases)
    }

    // MARK: - displayName

    @Test("displayName formats a category into a user-facing string")
    @MainActor
    func displayNameFormatsCategory() throws {
        // GIVEN a view model
        let container = try Self.makeContainer()
        let viewModel = CategoryPickerViewModel(
            transactionID: UUID(),
            container: container
        )
        // WHEN formatting .travel
        let result = viewModel.displayName(for: .travel)
        // THEN the result contains "Travel"
        #expect(result.contains("Travel"))
    }
}
