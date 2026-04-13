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
    @State private var errorMessage: String?

    init(transaction: CardTransaction) {
        self._viewModel = State(initialValue: .init(transaction: transaction))
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
                LabeledContent("Category", value: viewModel.category)
                if isEditing {
                    EditableLabeledContent("Merchant", text: $viewModel.merchant)
                    EditableLabeledContent("Card", text: $viewModel.card)
                } else {
                    LabeledContent("Merchant", value: viewModel.merchant)
                    LabeledContent("Card", value: viewModel.card)
                }
                LabeledContent("Date", value: viewModel.formattedDate)
            }
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
                    "category": "\(viewModel.category)"
                ]
            )
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
