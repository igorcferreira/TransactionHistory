//
//  TransactionListGroupViewModel.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import SwiftUI
import SwiftData

@Observable
@MainActor
final class TransactionListGroupViewModel {
    // MARK: - Setup
    func createQuery(
        search: String,
        sortOrder: SortOrder
    ) -> Query<CardTransaction, [CardTransaction]> {
        let predicate: Predicate<CardTransaction>

        if search.isEmpty {
            predicate = #Predicate { _ in true }
        } else {
            predicate = #Predicate {
                $0.merchant.localizedStandardContains(search)
            }
        }

        return .init(
            filter: predicate,
            sort: [SortDescriptor(\.createdAt, order: sortOrder)]
        )
    }

    // MARK: - Formatting

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

    // MARK: - Grouping

    func grouped(
        transactions: [CardTransaction],
        sortOrder: SortOrder
    ) -> [TransactionGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transaction.createdAt)
        }
        let ascending = sortOrder == .forward
        return grouped
            .sorted { ascending ? $0.key < $1.key : $0.key > $1.key }
            .map { TransactionGroup(date: $0.key, transactions: $0.value) }
    }
}
