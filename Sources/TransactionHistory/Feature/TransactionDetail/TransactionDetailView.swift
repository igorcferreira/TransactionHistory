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
    private let viewModel: TransactionDetailViewModel

    init(transaction: CardTransaction) {
        self.viewModel = TransactionDetailViewModel(transaction: transaction)
    }

    var body: some View {
        List {
            Section("Transaction") {
                LabeledContent("Name", value: viewModel.name)
                LabeledContent("Amount", value: viewModel.formattedAmount)
                LabeledContent("Currency", value: viewModel.currency)
            }
            Section("Details") {
                LabeledContent("Category", value: viewModel.category)
                LabeledContent("Merchant", value: viewModel.merchant)
                LabeledContent("Card", value: viewModel.card)
                LabeledContent("Date", value: viewModel.formattedDate)
            }
        }
        .navigationTitle(viewModel.name)
        .onAppear {
            logger.info(
                "Displayed transaction detail",
                metadata: [
                    "transactionID": "\(viewModel.id.uuidString)",
                    "merchant": "\(viewModel.merchant)",
                    "category": "\(viewModel.category)"
                ]
            )
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
