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

    // MARK: - Grouped transactions

    @Test("groupedTransactions groups by calendar date")
    func groupedTransactionsGroupsByDate() throws {
        // GIVEN transactions on two different days
        let context = try Self.makeContext()
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        for index in 0..<3 {
            let transaction = CardTransaction(
                name: "Today \(index)",
                currency: "EUR",
                amount: 1.0,
                merchant: "Merchant",
                card: "Card",
                createdAt: today.addingTimeInterval(TimeInterval(index * 60))
            )
            context.insert(transaction)
        }
        for index in 0..<2 {
            let transaction = CardTransaction(
                name: "Yesterday \(index)",
                currency: "EUR",
                amount: 1.0,
                merchant: "Merchant",
                card: "Card",
                createdAt: yesterday.addingTimeInterval(TimeInterval(index * 60))
            )
            context.insert(transaction)
        }
        try context.save()

        let viewModel = TransactionListViewModel()

        // WHEN loading
        viewModel.reload(context: context)

        // THEN transactions are grouped into two date sections
        let groups = viewModel.groupedTransactions
        #expect(groups.count == 2)
        let totalCount = groups.reduce(0) { $0 + $1.transactions.count }
        #expect(totalCount == 5)
    }

    @Test("sectionTitle returns Today for today's date")
    func sectionTitleToday() {
        // GIVEN today's date
        let viewModel = TransactionListViewModel()

        // WHEN getting the section title
        let title = viewModel.sectionTitle(for: Date())

        // THEN it returns "Today"
        #expect(title == String(localized: "Today"))
    }

    @Test("sectionTitle returns Yesterday for yesterday's date")
    func sectionTitleYesterday() {
        // GIVEN yesterday's date
        let viewModel = TransactionListViewModel()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

        // WHEN getting the section title
        let title = viewModel.sectionTitle(for: yesterday)

        // THEN it returns "Yesterday"
        #expect(title == String(localized: "Yesterday"))
    }

    @Test("sectionTitle returns formatted date for older dates")
    func sectionTitleOlderDate() {
        // GIVEN a date from last week
        let viewModel = TransactionListViewModel()
        let oldDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!

        // WHEN getting the section title
        let title = viewModel.sectionTitle(for: oldDate)

        // THEN it does not return Today or Yesterday
        #expect(title != String(localized: "Today"))
        #expect(title != String(localized: "Yesterday"))
        #expect(!title.isEmpty)
    }

    @Test("groupedTransactions respects sort order")
    func groupedTransactionsRespectsOrder() throws {
        // GIVEN transactions on two different days
        let context = try Self.makeContext()
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let todayTransaction = CardTransaction(
            name: "Today", currency: "EUR", amount: 1.0,
            merchant: "Merchant", card: "Card", createdAt: today
        )
        let yesterdayTransaction = CardTransaction(
            name: "Yesterday", currency: "EUR", amount: 1.0,
            merchant: "Merchant", card: "Card", createdAt: yesterday
        )
        context.insert(todayTransaction)
        context.insert(yesterdayTransaction)
        try context.save()

        let viewModel = TransactionListViewModel()

        // WHEN loading with newest first (reverse)
        viewModel.sortOrder = .reverse
        viewModel.reload(context: context)

        // THEN today's group comes first
        let reverseGroups = viewModel.groupedTransactions
        #expect(reverseGroups.count == 2)
        #expect(Calendar.current.isDateInToday(reverseGroups[0].date))
        #expect(Calendar.current.isDateInYesterday(reverseGroups[1].date))

        // WHEN switching to oldest first (forward)
        viewModel.sortOrder = .forward
        viewModel.reload(context: context)

        // THEN yesterday's group comes first
        let forwardGroups = viewModel.groupedTransactions
        #expect(forwardGroups.count == 2)
        #expect(Calendar.current.isDateInYesterday(forwardGroups[0].date))
        #expect(Calendar.current.isDateInToday(forwardGroups[1].date))
    }

    @Test("Search filters affect grouped transactions")
    func searchFiltersAffectGroupedTransactions() throws {
        // GIVEN transactions with different merchants across two days
        let context = try Self.makeContext()
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        // Two "Coffee" transactions today, one "Book" transaction yesterday
        for index in 0..<2 {
            let transaction = CardTransaction(
                name: "Coffee \(index)", currency: "EUR", amount: 1.0,
                merchant: "Coffee Shop", card: "Card",
                createdAt: today.addingTimeInterval(TimeInterval(index * 60))
            )
            context.insert(transaction)
        }
        let bookTransaction = CardTransaction(
            name: "Book", currency: "EUR", amount: 1.0,
            merchant: "Book Store", card: "Card", createdAt: yesterday
        )
        context.insert(bookTransaction)
        try context.save()

        let viewModel = TransactionListViewModel()

        // WHEN searching for "Coffee"
        viewModel.searchText = "Coffee"
        viewModel.reload(context: context)

        // THEN only one date group remains (today) with 2 transactions
        let groups = viewModel.groupedTransactions
        #expect(groups.count == 1)
        #expect(groups[0].transactions.count == 2)
        #expect(Calendar.current.isDateInToday(groups[0].date))
    }

    @Test("Search with no matches produces empty grouped transactions")
    func searchNoMatchesProducesEmptyGroups() throws {
        // GIVEN transactions
        let context = try Self.makeContext()
        try Self.seed(3, in: context, merchant: "Coffee Shop")
        let viewModel = TransactionListViewModel()

        // WHEN searching for a non-existent merchant
        viewModel.searchText = "Nonexistent"
        viewModel.reload(context: context)

        // THEN grouped transactions is also empty
        #expect(viewModel.groupedTransactions.isEmpty)
    }
}
