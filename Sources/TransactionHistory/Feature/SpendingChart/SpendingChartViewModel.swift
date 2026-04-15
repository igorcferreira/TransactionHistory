//
//  SpendingChartViewModel.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 15/04/2026.
//

import Foundation

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

    /// Whether there are multiple currencies to choose from.
    var hasMultipleCurrencies: Bool {
        availableCurrencies.count > 1
    }

    /// Whether there is no spending data to display.
    var isEmpty: Bool {
        categoryTotals.isEmpty
    }

    /// Filters, groups, and aggregates transactions. Call this when the
    /// transaction list changes; it auto-selects the most common currency.
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

    /// Re-aggregates for the currently selected currency without
    /// recomputing currency lists or auto-selecting. Call this when
    /// only `selectedCurrency` changes (e.g. picker interaction).
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
