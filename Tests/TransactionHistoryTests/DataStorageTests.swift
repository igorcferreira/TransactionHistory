//
//  DataStorageTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 13/03/2026.
//
import Foundation
import SwiftData
import Testing
@testable import TransactionHistory

@Suite("DataStorage")
struct DataStorageTests {

    // MARK: - Helpers

    /// Creates an in-memory ModelContainer with no CloudKit sync.
    private static func makeContainer() throws -> ModelContainer {
        let schema = Schema([CardTransaction.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [config])
    }

    /// Creates a DataStorage backed by an ephemeral in-memory container.
    private static func makeStorage() throws -> DataStorage {
        DataStorage(container: try makeContainer())
    }

    /// Inserts transactions into the storage with sequential dates.
    /// The first transaction in the array gets the oldest date.
    @discardableResult
    private static func seed(
        _ count: Int,
        in storage: DataStorage
    ) throws -> [CardTransaction] {
        let context = storage.modelContext
        var transactions: [CardTransaction] = []
        for index in 0..<count {
            let transaction = CardTransaction(
                name: "Transaction \(index)",
                currency: "EUR",
                amount: Double(index) + 1.0,
                merchant: "Merchant",
                card: "Card",
                createdAt: Date(timeIntervalSince1970: TimeInterval(index * 60))
            )
            context.insert(transaction)
            transactions.append(transaction)
        }
        try context.save()
        return transactions
    }

    // MARK: - top()

    @Test("top() returns empty array when database is empty")
    func topEmpty() throws {
        // GIVEN an empty database
        let storage = try Self.makeStorage()
        // WHEN fetching the top transactions
        let result = try storage.top()
        // THEN no transactions are returned
        #expect(result.isEmpty)
    }

    @Test("top() returns all transactions when fewer than 10 exist")
    func topFewerThanLimit() throws {
        // GIVEN a database with 5 transactions
        let storage = try Self.makeStorage()
        try Self.seed(5, in: storage)
        // WHEN fetching the top transactions
        let result = try storage.top()
        // THEN all 5 transactions are returned
        #expect(result.count == 5)
    }

    @Test("top() returns exactly 10 when more than 10 exist")
    func topMoreThanLimit() throws {
        // GIVEN a database with 15 transactions
        let storage = try Self.makeStorage()
        try Self.seed(15, in: storage)
        // WHEN fetching the top transactions
        let result = try storage.top()
        // THEN exactly 10 transactions are returned
        #expect(result.count == 10)
    }

    @Test("top() returns transactions sorted by createdAt descending")
    func topSortOrder() throws {
        // GIVEN a database with 5 transactions with sequential dates
        let storage = try Self.makeStorage()
        try Self.seed(5, in: storage)
        // WHEN fetching the top transactions
        let result = try storage.top()
        // THEN the transactions are ordered newest first
        let dates = result.map(\.createdAt)
        #expect(dates == dates.sorted(by: >))
    }

    // MARK: - with(ids:)

    @Test("with(ids:) returns empty array when no IDs match")
    func withIdsNoMatch() throws {
        // GIVEN a database with transactions
        let storage = try Self.makeStorage()
        try Self.seed(3, in: storage)
        // WHEN querying with non-existent IDs
        let result = try storage.with(ids: [UUID(), UUID()])
        // THEN no transactions are returned
        #expect(result.isEmpty)
    }

    @Test("with(ids:) returns matching transactions")
    func withIdsMatch() throws {
        // GIVEN a database with 3 transactions
        let storage = try Self.makeStorage()
        let seeded = try Self.seed(3, in: storage)
        let targetIDs = seeded.map(\.id)
        // WHEN querying with all their IDs
        let result = try storage.with(ids: targetIDs)
        // THEN all 3 transactions are returned
        #expect(result.count == 3)
        let resultIDs = Set(result.map(\.id))
        #expect(resultIDs == Set(targetIDs))
    }

    @Test("with(ids:) returns only matching subset")
    func withIdsPartialMatch() throws {
        // GIVEN a database with 5 transactions
        let storage = try Self.makeStorage()
        let seeded = try Self.seed(5, in: storage)
        // WHEN querying with 2 existing IDs and 1 non-existent ID
        let targetIDs = [seeded[0].id, seeded[3].id]
        let queryIDs = targetIDs + [UUID()]
        let result = try storage.with(ids: queryIDs)
        // THEN only the 2 matching transactions are returned
        #expect(result.count == 2)
        let resultIDs = Set(result.map(\.id))
        #expect(resultIDs == Set(targetIDs))
    }

    // MARK: - create()

    @Test("create() inserts a transaction with the correct field values")
    func createInsertsTransaction() throws {
        // GIVEN an empty database
        let storage = try Self.makeStorage()
        // WHEN creating a transaction
        let created = try storage.create(
            name: "Lunch",
            currency: "EUR",
            amount: 12.50,
            merchant: "Bistro",
            card: "Visa"
        )
        // THEN the returned object has the expected values
        #expect(created.name == "Lunch")
        #expect(created.currency == "EUR")
        #expect(created.amount == 12.50)
        #expect(created.merchant == "Bistro")
        #expect(created.card == "Visa")
    }

    @Test("create() persists the transaction so it is fetchable")
    func createPersistsTransaction() throws {
        // GIVEN an empty database
        let storage = try Self.makeStorage()
        // WHEN creating a transaction
        let created = try storage.create(
            name: "Groceries",
            currency: "USD",
            amount: 45.00,
            merchant: "FreshMart",
            card: "Mastercard"
        )
        // THEN the transaction is retrievable by its ID
        let fetched = try storage.with(ids: [created.id])
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Groceries")
    }

    @Test("create() uses the provided date for createdAt")
    func createUsesProvidedDate() throws {
        // GIVEN an empty database and a specific date
        let storage = try Self.makeStorage()
        let specificDate = Date(timeIntervalSince1970: 1_000_000)
        // WHEN creating a transaction with that date
        let created = try storage.create(
            name: "Old Purchase",
            currency: "EUR",
            amount: 5.00,
            merchant: "Shop",
            card: "Card",
            createdAt: specificDate
        )
        // THEN createdAt matches the provided date
        #expect(created.createdAt == specificDate)
    }

    @Test("create() defaults createdAt to approximately now")
    func createDefaultsToNow() throws {
        // GIVEN an empty database
        let storage = try Self.makeStorage()
        // WHEN creating a transaction without specifying a date
        let before = Date()
        let created = try storage.create(
            name: "Recent",
            currency: "EUR",
            amount: 1.00,
            merchant: "Corner Shop",
            card: "Card"
        )
        let after = Date()
        // THEN createdAt is approximately now
        #expect(created.createdAt >= before && created.createdAt <= after)
    }

    @Test("create() uses the provided ID")
    func createUsesProvidedID() throws {
        // GIVEN an empty database and a specific UUID
        let storage = try Self.makeStorage()
        let customID = UUID()
        // WHEN creating a transaction with that ID
        let created = try storage.create(
            id: customID,
            name: "Custom ID",
            currency: "EUR",
            amount: 10.00,
            merchant: "Store",
            card: "Card"
        )
        // THEN the transaction has the provided ID
        #expect(created.id == customID)
    }

    @Test("create() can insert multiple transactions")
    func createMultiple() throws {
        // GIVEN an empty database
        let storage = try Self.makeStorage()
        // WHEN creating multiple transactions
        _ = try storage.create(
            name: "First", currency: "EUR", amount: 1.00,
            merchant: "A", card: "Card"
        )
        _ = try storage.create(
            name: "Second", currency: "USD", amount: 2.00,
            merchant: "B", card: "Card"
        )
        _ = try storage.create(
            name: "Third", currency: "GBP", amount: 3.00,
            merchant: "C", card: "Card"
        )
        // THEN all three are present in the database
        let result = try storage.top()
        #expect(result.count == 3)
    }
}
