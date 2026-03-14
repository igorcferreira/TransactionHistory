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
        VStack(spacing: 0) {
            TransactionListHeaderView(
                searchText: $viewModel.searchText,
                sortOrder: $viewModel.sortOrder
            )
            List {
                ForEach(viewModel.transactions) { transaction in
                    ShortTransactionView(transaction: transaction)
                        .onAppear {
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
            .listStyle(.plain)
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
