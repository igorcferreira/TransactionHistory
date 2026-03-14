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

// MARK: - Header with search and sort controls

private struct TransactionListHeaderView: View {
    @Binding var searchText: String
    @Binding var sortOrder: SortOrder

    var body: some View {
        VStack(spacing: 8) {
            SearchFieldView(text: $searchText)
            SortPickerView(sortOrder: $sortOrder)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Inline search field

private struct SearchFieldView: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search by merchant", text: $text)
                .textFieldStyle(.plain)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Sort order picker

private struct SortPickerView: View {
    @Binding var sortOrder: SortOrder

    var body: some View {
        Picker("Sort", selection: $sortOrder) {
            Text("Newest First").tag(SortOrder.reverse)
            Text("Oldest First").tag(SortOrder.forward)
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    TransactionListView()
        .includingMocks()
}
