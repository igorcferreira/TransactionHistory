//
//  SpendingChartView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 15/04/2026.
//

import Charts
import SwiftData
import SwiftUI

/// Displays a pie chart of total spending per category.
struct SpendingChartView: View {
    @Query private var transactions: [CardTransaction]
    @State private var viewModel = SpendingChartViewModel()

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
        .navigationTitle("Spending by Category")
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
