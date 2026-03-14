//
//  TransactionListViewModel.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import Foundation
import SwiftData

/// Manages batched loading, sorting, and merchant search for the transaction list.
@Observable
final class TransactionListViewModel {

    // MARK: - Public state

    /// Loaded transactions for the current query.
    private(set) var transactions: [CardTransaction] = [] {
        didSet { rebuildGroupedTransactions() }
    }

    /// Transactions grouped by calendar date, ordered consistently with `sortOrder`.
    /// Rebuilt automatically when `transactions` or `sortOrder` change.
    private(set) var groupedTransactions: [TransactionGroup] = []

    /// Returns a display label for a section date (e.g. "Today", "Yesterday", or a formatted date).
    func sectionTitle(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return String(localized: "Today")
        } else if calendar.isDateInYesterday(date) {
            return String(localized: "Yesterday")
        } else {
            return date.formatted(.dateTime.day().month(.wide).year())
        }
    }

    /// Free-text filter applied against merchant name.
    var searchText: String = ""

    /// Sort direction for `createdAt`.
    var sortOrder: SortOrder = .reverse {
        didSet { rebuildGroupedTransactions() }
    }

    /// Whether more items may be available beyond the current batch.
    private(set) var hasMoreItems = true

    // MARK: - Private state

    private let batchSize = 20
    private var currentOffset = 0

    // MARK: - Loading

    /// Resets pagination and loads the first batch.
    func reload(context: ModelContext) {
        currentOffset = 0
        transactions = []
        hasMoreItems = true
        loadNextBatch(context: context)
    }

    /// Appends the next page of transactions from the data store.
    func loadNextBatch(context: ModelContext) {
        guard hasMoreItems else { return }

        var descriptor = FetchDescriptor<CardTransaction>(
            sortBy: [SortDescriptor(\.createdAt, order: sortOrder)]
        )

        // Filter by merchant name when search text is present.
        if !searchText.isEmpty {
            let search = searchText
            descriptor.predicate = #Predicate<CardTransaction> {
                $0.merchant.localizedStandardContains(search)
            }
        }

        descriptor.fetchOffset = currentOffset
        descriptor.fetchLimit = batchSize

        do {
            let batch = try context.fetch(descriptor)
            transactions.append(contentsOf: batch)
            currentOffset += batch.count
            hasMoreItems = batch.count == batchSize
        } catch {
            hasMoreItems = false
        }
    }

    // MARK: - Grouping

    private func rebuildGroupedTransactions() {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transaction.createdAt)
        }
        let ascending = sortOrder == .forward
        groupedTransactions = grouped
            .sorted { ascending ? $0.key < $1.key : $0.key > $1.key }
            .map { TransactionGroup(date: $0.key, transactions: $0.value) }
    }
}

/// A group of transactions sharing the same calendar date.
struct TransactionGroup: Identifiable {
    let date: Date
    let transactions: [CardTransaction]

    var id: Date { date }
}
