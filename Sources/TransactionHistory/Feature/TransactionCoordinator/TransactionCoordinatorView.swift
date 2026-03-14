//
//  TransactionCoordinatorView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import SwiftUI

/// Root view that hosts the NavigationStack and coordinates navigation
/// between the transaction list and detail screens.
public struct TransactionCoordinatorView: View {
    @State private var viewModel = TransactionCoordinatorViewModel()

    public init() {}

    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            TransactionListView(
                onTransactionTapped: viewModel.showDetail
            )
            .navigationDestination(for: CardTransaction.self) { transaction in
                TransactionDetailView(transaction: transaction)
            }
        }
    }
}

#Preview {
    TransactionCoordinatorView()
        .includingMocks()
}
