//
//  TransactionDetailView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import Logging
import SwiftUI

struct TransactionDetailView: View {
    @Environment(\.transactionHistoryLogger) private var logger
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TransactionDetailViewModel
    @State private var isEditing = false
    @State private var isConfirmingDelete = false
    @State private var errorMessage: String?

    /// Called after the transaction has been successfully deleted.
    var onTransactionDeleted: (() -> Void)?

    init(
        transaction: CardTransaction,
        onTransactionDeleted: (() -> Void)? = nil
    ) {
        self._viewModel = State(initialValue: .init(transaction: transaction))
        self.onTransactionDeleted = onTransactionDeleted
    }

    var body: some View {
        let detailLogger = logger.scoped("feature.transactionDetail")

        List {
            Section("Transaction") {
                if isEditing {
                    EditableLabeledContent("Name", text: $viewModel.name)
                } else {
                    LabeledContent("Name", value: viewModel.name)
                }
                LabeledContent("Amount", value: viewModel.formattedAmount)
                LabeledContent("Currency", value: viewModel.currency)
            }
            Section("Details") {
                if isEditing {
                    Picker("Category", selection: $viewModel.category) {
                        ForEach(viewModel.selectableCategories, id: \.self) { category in
                            Text(viewModel.displayName(for: category))
                                .tag(category)
                        }
                    }
                    EditableLabeledContent("Merchant", text: $viewModel.merchant)
                    EditableLabeledContent("Card", text: $viewModel.card)
                } else {
                    LabeledContent("Category", value: viewModel.categoryDisplayName)
                    LabeledContent("Merchant", value: viewModel.merchant)
                    LabeledContent("Card", value: viewModel.card)
                }
                LabeledContent("Date", value: viewModel.formattedDate)
            }
            if isEditing {
                Section {
                    Button("Delete Transaction", role: .destructive) {
                        isConfirmingDelete = true
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .confirmationDialog(
            "Delete Transaction",
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) { deleteTransaction() }
        } message: {
            Text("This transaction will be permanently deleted.")
        }
        .toast(message: $errorMessage)
        .navigationTitle(viewModel.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        detailLogger.info("Cancelled transaction edit")
                        viewModel.revert()
                        isEditing = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            } else {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        detailLogger.info("Entered edit mode")
                        isEditing = true
                    }
                }
            }
        }
        .onAppear {
            detailLogger.info(
                "Displayed transaction detail",
                metadata: [
                    "transactionID": "\(viewModel.id.uuidString)",
                    "merchant": "\(viewModel.merchant)",
                    "category": "\(viewModel.categoryDisplayName)"
                ]
            )
        }
    }

    private func deleteTransaction() {
        let detailLogger = logger.scoped("feature.transactionDetail")
        do {
            try viewModel.delete(on: modelContext)
            detailLogger.info(
                "Transaction deleted",
                metadata: ["id": "\(viewModel.id.uuidString)"]
            )
            onTransactionDeleted?()
        } catch {
            detailLogger.error(
                "Failed to delete transaction",
                metadata: ["error": "\(error)"]
            )
            withAnimation {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func save() {
        let detailLogger = logger.scoped("feature.transactionDetail")
        do {
            try viewModel.save(on: modelContext)
            detailLogger.info(
                "Transaction updated",
                metadata: ["id": "\(viewModel.id.uuidString)"]
            )
            isEditing = false
        } catch {
            detailLogger.error(
                "Failed to update transaction",
                metadata: ["error": "\(error)"]
            )
            withAnimation {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    NavigationStack {
        TransactionDetailView(transaction: .init(
            name: "Coffee Purchase",
            currency: "EUR",
            amount: 4.50,
            merchant: "Coffee Corner",
            card: "Virtual Card",
            category: .generic
        ))
    }
}
