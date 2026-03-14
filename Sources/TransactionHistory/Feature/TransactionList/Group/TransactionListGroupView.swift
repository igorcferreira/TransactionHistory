//
//  TransactionListGroupView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import SwiftUI
import SwiftData

struct TransactionListGroupView: View {

    @Query
    private var transactions: [CardTransaction]
    private let sortOrder: SortOrder
    private let viewModel: TransactionListGroupViewModel

    /// Called when the user taps a transaction row.
    var onTransactionTapped: ((CardTransaction) -> Void)?

    private var groups: [TransactionGroup] {
        viewModel.grouped(
            transactions: transactions,
            sortOrder: sortOrder
        )
    }

    init(
        search: String = "",
        sortOrder: SortOrder = .reverse,
        onTransactionTapped: ((CardTransaction) -> Void)? = nil
    ) {
        let viewModel = TransactionListGroupViewModel()

        self._transactions = viewModel.createQuery(
            search: search,
            sortOrder: sortOrder
        )
        self.sortOrder = sortOrder
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

#Preview("Reverse") {
    TransactionListGroupView()
        .includingMocks()
}

#Preview("Forward") {
    TransactionListGroupView(
        sortOrder: .forward
    ).includingMocks()
}

#Preview("Searching") {
    TransactionListGroupView(
        search: "Coff"
    ).includingMocks()
}
