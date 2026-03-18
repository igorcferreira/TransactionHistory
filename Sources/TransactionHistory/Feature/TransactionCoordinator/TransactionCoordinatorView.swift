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
    @Environment(\.transactionHistoryLogger) private var logger
    @State private var viewModel = TransactionCoordinatorViewModel()

    public init() {}

    public var body: some View {
        let coordinatorLogger = logger.scoped("feature.transactionCoordinator")

        NavigationStack(path: $viewModel.path) {
            TransactionListView(
                onTransactionTapped: { transaction in
                    viewModel.showDetail(
                        for: transaction,
                        logger: coordinatorLogger
                    )
                },
                onAddTapped: {
                    viewModel.showCreateTransaction(logger: coordinatorLogger)
                }
            )
            .transactionHistoryLogger(
                coordinatorLogger.scoped("feature.transactionList")
            )
            .navigationDestination(for: CardTransaction.self) { transaction in
                TransactionDetailView(transaction: transaction)
                    .transactionHistoryLogger(
                        coordinatorLogger.scoped("feature.transactionDetail")
                    )
            }
            .sheet(isPresented: $viewModel.isAddingTransaction) {
                NavigationStack {
                    CreateTransactionView()
                        .transactionHistoryLogger(
                            coordinatorLogger.scoped("feature.createTransaction")
                        )
                }
            }
        }
        .onAppear {
            coordinatorLogger.info("Transaction coordinator displayed")
        }
    }
}

#Preview {
    TransactionCoordinatorView()
        .includingMocks()
}
