//
//  TransactionListViewModelTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 13/04/2026.
//

import Foundation
import SwiftData
import Testing
@testable import TransactionHistory

@Suite("TransactionListViewModel")
struct TransactionListViewModelTests {

    // MARK: - Helpers

    /// Creates an in-memory ModelContainer for isolated tests.
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
        name: String = "Test",
        in context: ModelContext
    ) -> CardTransaction {
        let transaction = CardTransaction(
            name: name,
            currency: "EUR",
            amount: 10.0,
            merchant: "Merchant",
            card: "Card",
            category: .generic
        )
        context.insert(transaction)
        return transaction
    }

    // MARK: - deleteSelected

    @Test("deleteSelected removes only selected transactions")
    func deleteSelectedRemovesOnlySelected() throws {
        // GIVEN a context with three transactions and two selected
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        let first = Self.makeTransaction(name: "First", in: context)
        _ = Self.makeTransaction(name: "Second", in: context)
        let third = Self.makeTransaction(name: "Third", in: context)
        try context.save()

        let viewModel = TransactionListViewModel()
        viewModel.selection = [first.id, third.id]

        // WHEN deleting selected
        try viewModel.deleteSelected(on: context)

        // THEN only the unselected transaction remains
        let descriptor = FetchDescriptor<CardTransaction>()
        let remaining = try context.fetch(descriptor)
        #expect(remaining.count == 1)
        #expect(remaining.first?.name == "Second")
    }

    @Test("deleteSelected clears selection")
    func deleteSelectedClearsSelection() throws {
        // GIVEN a context with one selected transaction
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        let transaction = Self.makeTransaction(in: context)
        try context.save()

        let viewModel = TransactionListViewModel()
        viewModel.selection = [transaction.id]

        // WHEN deleting selected
        try viewModel.deleteSelected(on: context)

        // THEN selection is empty
        #expect(viewModel.selection.isEmpty)
    }

    // MARK: - hasSelection

    @Test("hasSelection is false when selection is empty")
    func hasSelectionFalseWhenEmpty() {
        // GIVEN a view model with no selection
        let viewModel = TransactionListViewModel()
        // THEN hasSelection is false
        #expect(!viewModel.hasSelection)
    }

    @Test("hasSelection is true when selection is non-empty")
    func hasSelectionTrueWhenNonEmpty() {
        // GIVEN a view model with a selected ID
        let viewModel = TransactionListViewModel()
        viewModel.selection = [UUID()]
        // THEN hasSelection is true
        #expect(viewModel.hasSelection)
    }
}
