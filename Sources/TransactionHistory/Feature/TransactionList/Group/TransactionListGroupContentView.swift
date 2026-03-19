//
//  TransactionListGroupContentView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 19/03/2026.
//
import SwiftUI

/// Renders grouped transactions as a sectioned list.
/// Separated from `TransactionListGroupView` so the rendering
/// logic can be tested with ViewInspector without requiring `@Query`.
struct TransactionListGroupContentView: View {
    private let groups: [TransactionGroup]
    private let viewModel: TransactionListGroupViewModel

    /// Called when the user taps a transaction row.
    var onTransactionTapped: ((CardTransaction) -> Void)?

    init(
        groups: [TransactionGroup],
        viewModel: TransactionListGroupViewModel = TransactionListGroupViewModel(),
        onTransactionTapped: ((CardTransaction) -> Void)? = nil
    ) {
        self.groups = groups
        self.viewModel = viewModel
        self.onTransactionTapped = onTransactionTapped
    }

    var body: some View {
        List {
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
        .listStyle(.plain)
        .id("transaction_list")
    }
}
