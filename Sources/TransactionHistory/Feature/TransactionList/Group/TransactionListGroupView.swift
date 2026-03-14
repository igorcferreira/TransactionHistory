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
                    ForEach(group.transactions) { transaction in
                        ShortTransactionView(
                            transaction: transaction
                        )
                    }
                } header: {
                    Text(viewModel.sectionTitle(for: group.date))
                        .font(.headline)
                        .textCase(.uppercase)
                }
            }
        }
        .listStyle(.plain)
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
