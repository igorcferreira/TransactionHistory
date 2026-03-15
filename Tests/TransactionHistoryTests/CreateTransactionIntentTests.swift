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

    /// Creates an in-memory ModelContext isolated from the shared container.
    private static func makeContext() throws -> ModelContext {
        let schema = Schema([CardTransaction.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    /// Fetches all CardTransactions from the given context.
    private static func fetchAll(
        from context: ModelContext
    ) throws -> [CardTransaction] {
        try context.fetch(FetchDescriptor<CardTransaction>())
    }

    // MARK: - createTransaction

    @Test("createTransaction inserts a transaction with correct field values")
    func createTransactionFieldValues() throws {
        // GIVEN an empty in-memory context
        let context = try Self.makeContext()
        let date = Date(timeIntervalSince1970: 1_000_000)
        // WHEN creating a transaction
        let created = try CreateTransactionIntent.createTransaction(
            name: "Lunch",
            merchant: "Bistro",
            amount: "€12.50",
            card: "Visa",
            date: date,
            context: context
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
        // GIVEN an empty in-memory context
        let context = try Self.makeContext()
        // WHEN creating a transaction
        let created = try CreateTransactionIntent.createTransaction(
            name: "Groceries",
            merchant: "FreshMart",
            amount: "$45.00",
            card: "Mastercard",
            date: Date(),
            context: context
        )
        // THEN the transaction is retrievable from the context
        let fetched = try Self.fetchAll(from: context)
        #expect(fetched.count == 1)
        #expect(fetched.first?.id == created.id)
        #expect(fetched.first?.name == "Groceries")
    }

    @Test("createTransaction throws invalidAmount for non-parseable input")
    func createTransactionInvalidAmount() throws {
        // GIVEN an empty in-memory context
        let context = try Self.makeContext()
        // WHEN creating a transaction with an invalid amount
        // THEN invalidAmount is thrown
        #expect(throws: CreateTransactionIntent.CreateTransactionError.invalidAmount) {
            try CreateTransactionIntent.createTransaction(
                name: "Bad",
                merchant: "Store",
                amount: "not-a-number",
                card: "Card",
                date: Date(),
                context: context
            )
        }
    }

    @Test("createTransaction can insert multiple transactions")
    func createTransactionMultiple() throws {
        // GIVEN an empty in-memory context
        let context = try Self.makeContext()
        // WHEN creating multiple transactions
        _ = try CreateTransactionIntent.createTransaction(
            name: "First", merchant: "A", amount: "€1.00",
            card: "Card", date: Date(), context: context
        )
        _ = try CreateTransactionIntent.createTransaction(
            name: "Second", merchant: "B", amount: "$2.00",
            card: "Card", date: Date(), context: context
        )
        _ = try CreateTransactionIntent.createTransaction(
            name: "Third", merchant: "C", amount: "£3.00",
            card: "Card", date: Date(), context: context
        )
        // THEN all three are present in the context
        let all = try Self.fetchAll(from: context)
        #expect(all.count == 3)
    }

    // MARK: - execute

    @Test("execute persists the transaction via the injected context")
    func executePersists() async throws {
        // GIVEN an empty in-memory context
        let context = try Self.makeContext()
        // WHEN executing the intent
        try await CreateTransactionIntent.execute(
            name: "Coffee",
            merchant: "Coffee Corner",
            amount: "€4.50",
            card: "Card 1",
            date: Date(timeIntervalSince1970: 500_000),
            context: context
        )
        // THEN the transaction is persisted in the context
        let fetched = try Self.fetchAll(from: context)
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
        // GIVEN an empty in-memory context
        let context = try Self.makeContext()
        // WHEN executing with an invalid amount
        // THEN invalidAmount is thrown
        await #expect(throws: CreateTransactionIntent.CreateTransactionError.invalidAmount) {
            try await CreateTransactionIntent.execute(
                name: "Bad",
                merchant: "Store",
                amount: "xyz",
                card: "Card",
                date: Date(),
                context: context
            )
        }
    }
}
