//
//  SpendingChartViewModel.swift
//  TransactionHistory
//

import Foundation
import SwiftData
import SwiftUI

// A year+month pair used to scope the chart to a single calendar month.
struct YearMonth: Hashable, Comparable {
    let year: Int
    let month: Int

    static var current: YearMonth {
        let components = Calendar.current.dateComponents([.year, .month], from: Date())
        return YearMonth(year: components.year ?? 0, month: components.month ?? 1)
    }

    func previous() -> YearMonth {
        month == 1 ? YearMonth(year: year - 1, month: 12) : YearMonth(year: year, month: month - 1)
    }

    func next() -> YearMonth {
        month == 12 ? YearMonth(year: year + 1, month: 1) : YearMonth(year: year, month: month + 1)
    }

    /// Locale-formatted string, e.g. "April 2026".
    var displayTitle: String {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        guard let date = Calendar.current.date(from: components) else { return "" }
        return date.formatted(.dateTime.month(.wide).year())
    }

    /// The full calendar month as a half-open interval [start, start+1 month).
    var dateInterval: DateInterval {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        let calendar = Calendar.current
        let start = calendar.date(from: components) ?? Date()
        let end = calendar.date(byAdding: .month, value: 1, to: start) ?? Date()
        return DateInterval(start: start, end: end)
    }

    static func < (lhs: YearMonth, rhs: YearMonth) -> Bool {
        lhs.year != rhs.year ? lhs.year < rhs.year : lhs.month < rhs.month
    }
}

/// Aggregates transaction data by category for chart display.
@Observable
@MainActor
final class SpendingChartViewModel {

    /// A single category's share of spending in a given currency.
    struct CategoryTotal: Identifiable {
        let id: UUID = UUID()
        let category: EntryCategory
        let currency: String
        let total: Double
        let percentage: Double

        /// Locale-formatted currency string (e.g. "€42.50").
        var formattedTotal: String {
            total.formatted(.currency(code: currency))
        }

        /// Percentage string (e.g. "35%").
        var formattedPercentage: String {
            percentage.formatted(.percent.precision(.fractionLength(0)))
        }
    }

    /// All distinct currencies found in the current transactions.
    private(set) var availableCurrencies: [String] = []

    /// The currency currently displayed in the chart.
    var selectedCurrency: String = ""

    /// Aggregated totals per category, sorted descending by amount.
    private(set) var categoryTotals: [CategoryTotal] = []

    /// The calendar month currently shown in the chart.
    var selectedYearMonth: YearMonth = .current

    /// Whether there are multiple currencies to choose from.
    var hasMultipleCurrencies: Bool {
        availableCurrencies.count > 1
    }

    /// Whether there is no spending data to display.
    var isEmpty: Bool {
        categoryTotals.isEmpty
    }

    /// Whether the user can navigate forward to a later month.
    var canGoToNextMonth: Bool {
        selectedYearMonth < .current
    }

    /// Moves back one calendar month.
    func goToPreviousMonth() {
        selectedYearMonth = selectedYearMonth.previous()
    }

    /// Moves forward one calendar month (capped at current month).
    func goToNextMonth() {
        selectedYearMonth = selectedYearMonth.next()
    }

    /// Returns a SwiftData query that fetches only transactions in the given month,
    /// letting the database engine apply the date filter rather than loading all rows.
    func createQuery(for month: YearMonth) -> Query<CardTransaction, [CardTransaction]> {
        let start = month.dateInterval.start
        let end = month.dateInterval.end
        return Query(
            filter: #Predicate<CardTransaction> { $0.createdAt >= start && $0.createdAt < end },
            sort: [SortDescriptor(\.createdAt, order: .reverse)]
        )
    }

    /// Groups and aggregates the provided transactions by category.
    /// The caller is responsible for supplying only the relevant transactions
    /// (date filtering is handled by the SwiftData query, not here).
    func aggregate(transactions: [CardTransaction]) {
        // Exclude NaN, infinite, and non-positive amounts (e.g. refunds).
        let valid = transactions.filter { $0.amount.isFinite && $0.amount > 0 }

        let byCurrency = Dictionary(grouping: valid) { $0.currency }
        availableCurrencies = byCurrency.keys.sorted()

        // Auto-select the currency with the most transactions if none is selected.
        if selectedCurrency.isEmpty || !byCurrency.keys.contains(selectedCurrency) {
            selectedCurrency = byCurrency
                .max { $0.value.count < $1.value.count }?.key ?? ""
        }

        buildTotals(from: byCurrency)
    }

    /// Re-aggregates for the currently selected currency without recomputing currency
    /// lists or auto-selecting. Call this when only `selectedCurrency` changes.
    func rebuildForSelectedCurrency(transactions: [CardTransaction]) {
        let valid = transactions.filter { $0.amount.isFinite && $0.amount > 0 }
        let byCurrency = Dictionary(grouping: valid) { $0.currency }
        buildTotals(from: byCurrency)
    }

    // MARK: - Private

    private func buildTotals(from byCurrency: [String: [CardTransaction]]) {
        guard let currencyTransactions = byCurrency[selectedCurrency] else {
            categoryTotals = []
            return
        }

        let byCategory = Dictionary(grouping: currencyTransactions) { $0.category }
        let grandTotal = currencyTransactions.reduce(0.0) { $0 + $1.amount }

        categoryTotals = byCategory.map { category, transactions in
            let sum = transactions.reduce(0.0) { $0 + $1.amount }
            let pct = grandTotal > 0 ? sum / grandTotal : 0
            return CategoryTotal(
                category: category,
                currency: selectedCurrency,
                total: sum,
                percentage: pct
            )
        }
        .sorted { $0.total > $1.total }
    }
}
