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
                ForEach(viewModel.groupedTransactions) { group in
                    Section {
                        ForEach(group.transactions) { transaction in
                            ShortTransactionView(
                                transaction: transaction
                            ).onAppear {
                                checkPage(id: transaction.id)
                            }
                        }
                    } header: {
                        Text(viewModel.sectionTitle(for: group.date))
                            .font(.headline)
                            .textCase(.uppercase)
                    }
                }
                if viewModel.hasMoreItems
                    && !viewModel.transactions.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .listStyle(.plain)
        }
        .refreshable {
            viewModel.reload(context: modelContext)
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

    private func checkPage(id: UUID) {
        if id == viewModel.transactions.last?.id {
            viewModel.loadNextBatch(context: modelContext)
        }
    }
}

#Preview {
    TransactionListView()
        .includingMocks()
}
