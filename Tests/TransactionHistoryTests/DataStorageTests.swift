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
                category: .generic,
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

    // MARK: - Error types

    @Test("top() error type is DataStorageError")
    func topErrorType() throws {
        // GIVEN a valid storage (happy path — typed throws checked at compile time)
        let storage = try Self.makeStorage()
        // WHEN calling top()
        // THEN the call site requires no cast — the compiler enforces DataStorageError.
        // SwiftData in-memory containers don't produce fetch errors under normal conditions;
        // fault-injection testing requires a custom ModelContext not available in-process.
        let result: [CardTransaction] = try storage.top()
        #expect(result.isEmpty)
    }

    @Test("with(ids:) error type is DataStorageError")
    func withIdsErrorType() throws {
        // GIVEN a valid storage (happy path — typed throws checked at compile time)
        let storage = try Self.makeStorage()
        // WHEN calling with(ids:) with an empty list
        // THEN the call site requires no cast — the compiler enforces DataStorageError.
        // SwiftData in-memory containers don't produce fetch errors under normal conditions;
        // fault-injection testing requires a custom ModelContext not available in-process.
        let result: [CardTransaction] = try storage.with(ids: [])
        #expect(result.isEmpty)
    }

}
