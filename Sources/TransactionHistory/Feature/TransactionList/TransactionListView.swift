//
//  TransactionListView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import Foundation
import Logging
import SwiftUI
import SwiftData

public struct TransactionListView: View {
    @Environment(\.transactionHistoryLogger) private var logger
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
        let listLogger = logger.scoped("feature.transactionList")

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
                    listLogger.info("Tapped add transaction")
                    onAddTapped?()
                } label: {
                    Label("Add Transaction", systemImage: "plus")
                }
            }
        }
        .onAppear {
            listLogger.info("Transaction list displayed")
        }
        .onChange(of: viewModel.searchText) {
            listLogger.debug(
                "Updated transaction search",
                metadata: [
                    "isActive": "\(!viewModel.searchText.isEmpty)",
                    "queryLength": "\(viewModel.searchText.count)"
                ]
            )
        }
        .onChange(of: viewModel.sortOrder) {
            listLogger.info(
                "Changed transaction sort order",
                metadata: ["sortOrder": "\(viewModel.sortOrder == .reverse ? "newestFirst" : "oldestFirst")"]
            )
        }
    }
}

#Preview {
    TransactionListView()
        .includingMocks()
}
