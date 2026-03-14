//
//  TransactionListViewModelTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import Foundation
import SwiftData
import Testing
@testable import TransactionHistory

@Suite("TransactionListViewModel")
struct TransactionListViewModelTests {

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

    private static func makeContext() throws -> ModelContext {
        ModelContext(try makeContainer())
    }

    /// Inserts transactions with sequential dates and alternating merchants.
    @discardableResult
    private static func seed(
        _ count: Int,
        in context: ModelContext,
        merchant: String = "Merchant"
    ) throws -> [CardTransaction] {
        var transactions: [CardTransaction] = []
        for index in 0..<count {
            let transaction = CardTransaction(
                name: "Transaction \(index)",
                currency: "EUR",
                amount: Double(index) + 1.0,
                merchant: merchant,
                card: "Card",
                createdAt: Date(timeIntervalSince1970: TimeInterval(index * 60))
            )
            context.insert(transaction)
            transactions.append(transaction)
        }
        try context.save()
        return transactions
    }

    // MARK: - reload

    @Test("reload loads the first batch of transactions")
    func reloadLoadsFirstBatch() throws {
        // GIVEN a database with 5 transactions
        let context = try Self.makeContext()
        try Self.seed(5, in: context)
        let viewModel = TransactionListViewModel()

        // WHEN reloading
        viewModel.reload(context: context)

        // THEN all 5 transactions are loaded
        #expect(viewModel.transactions.count == 5)
    }

    @Test("reload clears previous results before loading")
    func reloadClearsPreviousResults() throws {
        // GIVEN a view model that already loaded transactions
        let context = try Self.makeContext()
        try Self.seed(5, in: context)
        let viewModel = TransactionListViewModel()
        viewModel.reload(context: context)
        #expect(viewModel.transactions.count == 5)

        // WHEN reloading again
        viewModel.reload(context: context)

        // THEN the count stays the same (no duplicates)
        #expect(viewModel.transactions.count == 5)
    }

    // MARK: - Sort order

    @Test("Default sort order is newest first (reverse)")
    func defaultSortOrderIsReverse() throws {
        // GIVEN a database with sequential transactions
        let context = try Self.makeContext()
        try Self.seed(5, in: context)
        let viewModel = TransactionListViewModel()

        // WHEN loading with default sort
        viewModel.reload(context: context)

        // THEN transactions are sorted newest first
        let dates = viewModel.transactions.map(\.createdAt)
        #expect(dates == dates.sorted(by: >))
    }

    @Test("Sort order forward returns oldest first")
    func sortOrderForward() throws {
        // GIVEN a database with sequential transactions
        let context = try Self.makeContext()
        try Self.seed(5, in: context)
        let viewModel = TransactionListViewModel()
        viewModel.sortOrder = .forward

        // WHEN loading
        viewModel.reload(context: context)

        // THEN transactions are sorted oldest first
        let dates = viewModel.transactions.map(\.createdAt)
        #expect(dates == dates.sorted(by: <))
    }

    // MARK: - Merchant search

    @Test("Search filters transactions by merchant name")
    func searchFiltersByMerchant() throws {
        // GIVEN transactions with different merchants
        let context = try Self.makeContext()
        try Self.seed(3, in: context, merchant: "Coffee Shop")
        try Self.seed(2, in: context, merchant: "Book Store")
        let viewModel = TransactionListViewModel()

        // WHEN searching for "Coffee"
        viewModel.searchText = "Coffee"
        viewModel.reload(context: context)

        // THEN only Coffee Shop transactions are returned
        #expect(viewModel.transactions.count == 3)
        #expect(viewModel.transactions.allSatisfy { $0.merchant == "Coffee Shop" })
    }

    @Test("Empty search text returns all transactions")
    func emptySearchReturnsAll() throws {
        // GIVEN transactions with different merchants
        let context = try Self.makeContext()
        try Self.seed(3, in: context, merchant: "Coffee Shop")
        try Self.seed(2, in: context, merchant: "Book Store")
        let viewModel = TransactionListViewModel()

        // WHEN searching with empty text
        viewModel.searchText = ""
        viewModel.reload(context: context)

        // THEN all transactions are returned
        #expect(viewModel.transactions.count == 5)
    }

    @Test("Search with no matches returns empty results")
    func searchNoMatchesReturnsEmpty() throws {
        // GIVEN transactions
        let context = try Self.makeContext()
        try Self.seed(3, in: context, merchant: "Coffee Shop")
        let viewModel = TransactionListViewModel()

        // WHEN searching for a non-existent merchant
        viewModel.searchText = "Nonexistent"
        viewModel.reload(context: context)

        // THEN no transactions are returned
        #expect(viewModel.transactions.isEmpty)
    }

    // MARK: - Batch pagination

    @Test("hasMoreItems is false when all items fit in one batch")
    func hasMoreItemsFalseWhenFewItems() throws {
        // GIVEN fewer items than the batch size
        let context = try Self.makeContext()
        try Self.seed(5, in: context)
        let viewModel = TransactionListViewModel()

        // WHEN loading
        viewModel.reload(context: context)

        // THEN hasMoreItems is false
        #expect(!viewModel.hasMoreItems)
    }

    @Test("hasMoreItems is true when items equal batch size")
    func hasMoreItemsTrueWhenBatchFull() throws {
        // GIVEN exactly batch-size items (20)
        let context = try Self.makeContext()
        try Self.seed(20, in: context)
        let viewModel = TransactionListViewModel()

        // WHEN loading
        viewModel.reload(context: context)

        // THEN hasMoreItems is true (might be more)
        #expect(viewModel.hasMoreItems)
    }

    @Test("loadNextBatch appends to existing transactions")
    func loadNextBatchAppends() throws {
        // GIVEN 25 transactions (more than one batch)
        let context = try Self.makeContext()
        try Self.seed(25, in: context)
        let viewModel = TransactionListViewModel()

        // WHEN loading first batch then next
        viewModel.reload(context: context)
        let firstBatchCount = viewModel.transactions.count
        viewModel.loadNextBatch(context: context)

        // THEN the second batch is appended
        #expect(firstBatchCount == 20)
        #expect(viewModel.transactions.count == 25)
        #expect(!viewModel.hasMoreItems)
    }

    @Test("loadNextBatch does nothing when hasMoreItems is false")
    func loadNextBatchStopsWhenNoMore() throws {
        // GIVEN all items loaded
        let context = try Self.makeContext()
        try Self.seed(5, in: context)
        let viewModel = TransactionListViewModel()
        viewModel.reload(context: context)

        // WHEN calling loadNextBatch again
        viewModel.loadNextBatch(context: context)

        // THEN the count remains unchanged
        #expect(viewModel.transactions.count == 5)
    }
}
