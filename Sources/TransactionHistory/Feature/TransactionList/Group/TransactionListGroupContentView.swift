//
//  TransactionListGroupContentView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 19/03/2026.
//
import Logging
import SwiftUI

/// Renders grouped transactions as a sectioned list.
/// Separated from `TransactionListGroupView` so the rendering
/// logic can be tested with ViewInspector without requiring `@Query`.
struct TransactionListGroupContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.transactionHistoryLogger) private var logger

    private let groups: [TransactionGroup]
    private let viewModel: TransactionListGroupViewModel
    @State private var errorMessage: String?

    /// Called when the user taps a transaction row.
    var onTransactionTapped: ((CardTransaction) -> Void)?

    /// Binding for multi-select support in edit mode.
    @Binding var selection: Set<UUID>

    /// Binding for the list's edit mode state.
    @Binding var editMode: EditMode

    init(
        groups: [TransactionGroup],
        viewModel: TransactionListGroupViewModel = TransactionListGroupViewModel(),
        selection: Binding<Set<UUID>> = .constant([]),
        editMode: Binding<EditMode> = .constant(.inactive),
        onTransactionTapped: ((CardTransaction) -> Void)? = nil
    ) {
        self.groups = groups
        self.viewModel = viewModel
        self._selection = selection
        self._editMode = editMode
        self.onTransactionTapped = onTransactionTapped
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(groups) { group in
                Section {
                    Iterate(group.transactions.enumerated()) { transaction in
                        Button {
                            onTransactionTapped?(transaction)
                        } label: {
                            ShortTransactionView(
                                transaction: transaction
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteTransaction(transaction)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .tag(transaction.id)
                    }
                } header: {
                    Text(viewModel.sectionTitle(for: group.date))
                        .font(.headline)
                        .textCase(.uppercase)
                        .id("section_\(group.id)_header")
                }
                .id("section_\(group.id)")
            }
        }
        .environment(\.editMode, $editMode)
        .listStyle(.plain)
        .toast(message: $errorMessage)
        .id("transaction_list")
    }

    private func deleteTransaction(_ transaction: CardTransaction) {
        let listLogger = logger.scoped("feature.transactionList")
        do {
            try modelContext.transaction {
                modelContext.delete(transaction)
                try modelContext.save()
            }
            listLogger.info(
                "Deleted transaction via swipe",
                metadata: ["id": "\(transaction.id.uuidString)"]
            )
        } catch {
            listLogger.error(
                "Failed to delete transaction",
                metadata: ["error": "\(error)"]
            )
            withAnimation {
                errorMessage = error.localizedDescription
            }
        }
    }
}
