//
//  TransactionCoordinatorView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import Logging
import SwiftData
import SwiftUI

/// Root view that hosts the NavigationStack and coordinates navigation
/// between the transaction list and detail screens.
public struct TransactionCoordinatorView: View {
    @Environment(\.transactionHistoryLogger) private var logger
    @Environment(\.notificationRouter) private var notificationRouter
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TransactionCoordinatorViewModel()
    @State private var editMode: EditMode = .inactive

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
                TransactionDetailView(
                    transaction: transaction,
                    onTransactionDeleted: {
                        viewModel.pop(logger: coordinatorLogger)
                    }
                )
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
        .onChange(of: notificationRouter.pendingDetailTransactionID) {
            guard let transactionID = notificationRouter.pendingDetailTransactionID else { return }
            notificationRouter.pendingDetailTransactionID = nil
            navigateToTransaction(
                id: transactionID,
                logger: coordinatorLogger
            )
        }
        .environment(\.editMode, $editMode)
    }

    private func navigateToTransaction(id: UUID, logger: Logger) {
        let context = ModelContext(modelContext.container)
        var descriptor = FetchDescriptor<CardTransaction>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        guard let transaction = try? context.fetch(descriptor).first else {
            logger.warning(
                "Could not navigate to transaction from notification",
                metadata: ["transactionID": "\(id.uuidString)"]
            )
            return
        }

        viewModel.popToRoot(logger: logger)
        viewModel.showDetail(for: transaction, logger: logger)
    }
}

#Preview {
    TransactionCoordinatorView()
        .includingMocks()
}
