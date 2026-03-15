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

    /// Called when the user taps a transaction in the list.
    var onTransactionTapped: ((CardTransaction) -> Void)?
    /// Called when the user taps the add button in the toolbar.
    var onAddTapped: (() -> Void)?

    public init(
        onTransactionTapped: ((CardTransaction) -> Void)? = nil,
        onAddTapped: (() -> Void)? = nil
    ) {
        self.onTransactionTapped = onTransactionTapped
        self.onAddTapped = onAddTapped
    }

    public var body: some View {
        VStack(spacing: 0) {
            TransactionListHeaderView(
                searchText: $viewModel.searchText,
                sortOrder: $viewModel.sortOrder
            )
            TransactionListGroupView(
                search: viewModel.searchText,
                sortOrder: viewModel.sortOrder,
                onTransactionTapped: onTransactionTapped
            )
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    onAddTapped?()
                } label: {
                    Label("Add Transaction", systemImage: "plus")
                }
            }
        }
    }
}

#Preview {
    TransactionListView()
        .includingMocks()
}
