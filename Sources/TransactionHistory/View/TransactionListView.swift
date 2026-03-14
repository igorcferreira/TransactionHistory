//
//  TransactionListView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import Foundation
import SwiftUI
import SwiftData

public struct TransactionListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TransactionListViewModel()

    public init() {}

    public var body: some View {
        List {
            ForEach(viewModel.transactions) { transaction in
                ShortTransactionView(transaction: transaction)
                    .onAppear {
                        // Trigger next batch when the last item becomes visible.
                        if transaction.id == viewModel.transactions.last?.id {
                            viewModel.loadNextBatch(context: modelContext)
                        }
                    }
            }
            if viewModel.hasMoreItems && !viewModel.transactions.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search by merchant")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Picker("Sort", selection: $viewModel.sortOrder) {
                    Label("Newest First", systemImage: "arrow.down")
                        .tag(SortOrder.reverse)
                    Label("Oldest First", systemImage: "arrow.up")
                        .tag(SortOrder.forward)
                }
                .pickerStyle(.segmented)
            }
        }
        .onAppear {
            if viewModel.transactions.isEmpty {
                viewModel.reload(context: modelContext)
            }
        }
        .onChange(of: viewModel.searchText) {
            viewModel.reload(context: modelContext)
        }
        .onChange(of: viewModel.sortOrder) {
            viewModel.reload(context: modelContext)
        }
    }
}

#Preview {
    TransactionListView()
        .includingMocks()
}
