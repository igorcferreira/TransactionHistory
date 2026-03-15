//
//  CreateTransactionIntentTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 15/03/2026.
//

import Foundation
import SwiftData
import Testing
@testable import TransactionHistory

@Suite("CreateTransactionIntent")
struct CreateTransactionIntentTests {

    // MARK: - Helpers

    /// Creates an in-memory ModelContainer isolated from the shared container.
    private static func makeContainer() throws -> ModelContainer {
        let schema = Schema([CardTransaction.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [config])
    }

    /// Fetches all CardTransactions from the given container.
    private static func fetchAll(
        from container: ModelContainer
    ) throws -> [CardTransaction] {
        let context = ModelContext(container)
        return try context.fetch(FetchDescriptor<CardTransaction>())
    }

    // MARK: - createTransaction

    @Test("createTransaction inserts a transaction with correct field values")
    func createTransactionFieldValues() throws {
        // GIVEN an intent backed by an empty in-memory container
        let container = try Self.makeContainer()
        let intent = CreateTransactionIntent(container: container)
        let date = Date(timeIntervalSince1970: 1_000_000)
        // WHEN creating a transaction
        let created = try intent.createTransaction(
            name: "Lunch",
            merchant: "Bistro",
            amount: "€12.50",
            card: "Visa",
            date: date
        )
        // THEN the returned object has the expected values
        #expect(created.name == "Lunch")
        #expect(created.currency == "EUR")
        #expect(created.amount == 12.50)
        #expect(created.merchant == "Bistro")
        #expect(created.card == "Visa")
        #expect(created.createdAt == date)
    }

    @Test("createTransaction persists the transaction so it is fetchable")
    func createTransactionPersists() throws {
        // GIVEN an intent backed by an empty in-memory container
        let container = try Self.makeContainer()
        let intent = CreateTransactionIntent(container: container)
        // WHEN creating a transaction
        let created = try intent.createTransaction(
            name: "Groceries",
            merchant: "FreshMart",
            amount: "$45.00",
            card: "Mastercard",
            date: Date()
        )
        // THEN the transaction is retrievable from the container
        let fetched = try Self.fetchAll(from: container)
        #expect(fetched.count == 1)
        #expect(fetched.first?.id == created.id)
        #expect(fetched.first?.name == "Groceries")
    }

    @Test("createTransaction throws invalidAmount for non-parseable input")
    func createTransactionInvalidAmount() throws {
        // GIVEN an intent backed by an empty in-memory container
        let container = try Self.makeContainer()
        let intent = CreateTransactionIntent(container: container)
        // WHEN creating a transaction with an invalid amount
        // THEN invalidAmount is thrown
        #expect(throws: CreateTransactionIntent.CreateTransactionError.invalidAmount) {
            try intent.createTransaction(
                name: "Bad",
                merchant: "Store",
                amount: "not-a-number",
                card: "Card",
                date: Date()
            )
        }
    }

    @Test("createTransaction can insert multiple transactions")
    func createTransactionMultiple() throws {
        // GIVEN an intent backed by an empty in-memory container
        let container = try Self.makeContainer()
        let intent = CreateTransactionIntent(container: container)
        // WHEN creating multiple transactions
        _ = try intent.createTransaction(
            name: "First", merchant: "A", amount: "€1.00",
            card: "Card", date: Date()
        )
        _ = try intent.createTransaction(
            name: "Second", merchant: "B", amount: "$2.00",
            card: "Card", date: Date()
        )
        _ = try intent.createTransaction(
            name: "Third", merchant: "C", amount: "£3.00",
            card: "Card", date: Date()
        )
        // THEN all three are present in the container
        let all = try Self.fetchAll(from: container)
        #expect(all.count == 3)
    }

    // MARK: - execute

    @Test("execute persists the transaction via the injected container")
    func executePersists() async throws {
        // GIVEN an empty in-memory container
        let container = try Self.makeContainer()
        // WHEN executing the intent
        try await CreateTransactionIntent.execute(
            name: "Coffee",
            merchant: "Coffee Corner",
            amount: "€4.50",
            card: "Card 1",
            date: Date(timeIntervalSince1970: 500_000),
            container: container
        )
        // THEN the transaction is persisted in the container
        let fetched = try Self.fetchAll(from: container)
        #expect(fetched.count == 1)
        let saved = try #require(fetched.first)
        #expect(saved.name == "Coffee")
        #expect(saved.merchant == "Coffee Corner")
        #expect(saved.currency == "EUR")
        #expect(saved.amount == 4.50)
        #expect(saved.card == "Card 1")
        #expect(saved.createdAt == Date(timeIntervalSince1970: 500_000))
    }

    @Test("execute throws invalidAmount for bad input")
    func executeInvalidAmount() async throws {
        // GIVEN an empty in-memory container
        let container = try Self.makeContainer()
        // WHEN executing with an invalid amount
        // THEN invalidAmount is thrown
        await #expect(throws: CreateTransactionIntent.CreateTransactionError.invalidAmount) {
            try await CreateTransactionIntent.execute(
                name: "Bad",
                merchant: "Store",
                amount: "xyz",
                card: "Card",
                date: Date(),
                container: container
            )
        }
    }
}
