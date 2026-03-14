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

    private var groups: [TransactionGroup] {
        viewModel.grouped(
            transactions: transactions,
            sortOrder: sortOrder
        )
    }

    init(
        search: String = "",
        sortOrder: SortOrder = .reverse
    ) {
        let viewModel = TransactionListGroupViewModel()

        self._transactions = viewModel.createQuery(
            search: search,
            sortOrder: sortOrder
        )
        self.sortOrder = sortOrder
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            ForEach(groups) { group in
                Section {
                    Iterate(group.transactions.enumerated()) {
                        ShortTransactionView(
                            transaction: $0
                        )
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
