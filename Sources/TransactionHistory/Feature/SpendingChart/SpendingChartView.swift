//
//  SpendingChartView.swift
//  TransactionHistory
//

import Charts
import SwiftData
import SwiftUI

/// Displays a per-month pie chart of spending by category.
///
/// Navigation state lives here; `SpendingChartContent` owns the `@Query` so SwiftData
/// applies the date filter in the database rather than loading every transaction.
struct SpendingChartView: View {
    @State private var viewModel = SpendingChartViewModel()

    var body: some View {
        VStack(spacing: 0) {
            monthNavigationBar
                .padding(.horizontal)
                .padding(.vertical, 8)

            // Passing selectedYearMonth explicitly causes the child init to re-run
            // whenever the month changes, which updates the @Query predicate.
            SpendingChartContent(viewModel: viewModel, selectedYearMonth: viewModel.selectedYearMonth)
        }
        .navigationTitle("Spending by Category")
    }

    private var monthNavigationBar: some View {
        HStack {
            Button {
                viewModel.goToPreviousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
            }
            Spacer()
            Text(viewModel.selectedYearMonth.displayTitle)
                .font(.headline)
            Spacer()
            Button {
                viewModel.goToNextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .imageScale(.large)
            }
            .disabled(!viewModel.canGoToNextMonth)
        }
    }
}

// MARK: - Content (owns the filtered @Query)

/// Renders the chart for a specific month.
/// Its `init` rebuilds the `@Query` predicate whenever `selectedYearMonth` changes,
/// so the database engine does the filtering instead of in-memory iteration.
private struct SpendingChartContent: View {
    @Query private var transactions: [CardTransaction]
    @Bindable var viewModel: SpendingChartViewModel

    init(viewModel: SpendingChartViewModel, selectedYearMonth: YearMonth) {
        self._transactions = viewModel.createQuery(for: selectedYearMonth)
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            if viewModel.isEmpty {
                ContentUnavailableView(
                    "No Spending Data",
                    systemImage: "chart.pie",
                    description: Text("Add transactions to see spending by category.")
                )
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        currencyPicker
                        pieChart
                        summaryList
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            viewModel.aggregate(transactions: transactions)
        }
        .onChange(of: transactions) {
            viewModel.aggregate(transactions: transactions)
        }
        .onChange(of: viewModel.selectedCurrency) {
            viewModel.rebuildForSelectedCurrency(transactions: transactions)
        }
    }

    @ViewBuilder
    private var currencyPicker: some View {
        if viewModel.hasMultipleCurrencies {
            Picker("Currency", selection: $viewModel.selectedCurrency) {
                ForEach(viewModel.availableCurrencies, id: \.self) { currency in
                    Text(currency).tag(currency)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var pieChart: some View {
        Chart(viewModel.categoryTotals) { item in
            SectorMark(
                angle: .value("Amount", item.total),
                angularInset: 1.5
            )
            .foregroundStyle(by: .value("Category", item.category.rawValue))
        }
        .frame(height: 300)
    }

    private var summaryList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.categoryTotals) { item in
                HStack {
                    Text(item.category.rawValue)
                    Spacer()
                    Text(item.formattedPercentage)
                        .foregroundStyle(.secondary)
                    Text(item.formattedTotal)
                        .monospacedDigit()
                }
                .padding(.vertical, 8)
                Divider()
            }
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        SpendingChartView()
    }
    .includingMocks()
}

#Preview("Empty State") {
    NavigationStack {
        SpendingChartView()
    }
    .modelContainer(for: CardTransaction.self, inMemory: true)
}
