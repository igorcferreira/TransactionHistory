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

    /// Binding for multi-select support in edit mode.
    @Binding var selection: Set<UUID>

    private var groups: [TransactionGroup] {
        viewModel.grouped(
            transactions: transactions,
            sortOrder: sortOrder
        )
    }

    init(
        search: String = "",
        sortOrder: SortOrder = .reverse,
        selection: Binding<Set<UUID>> = .constant([]),
        onTransactionTapped: ((CardTransaction) -> Void)? = nil
    ) {
        let viewModel = TransactionListGroupViewModel()

        self._transactions = viewModel.createQuery(
            search: search,
            sortOrder: sortOrder
        )
        self.sortOrder = sortOrder
        self.viewModel = viewModel
        self._selection = selection
        self.onTransactionTapped = onTransactionTapped
    }

    var body: some View {
        TransactionListGroupContentView(
            groups: groups,
            viewModel: viewModel,
            selection: $selection,
            onTransactionTapped: onTransactionTapped
        )
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
