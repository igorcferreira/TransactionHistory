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
    private let viewModel: TransactionDetailViewModel

    init(transaction: CardTransaction) {
        self.viewModel = TransactionDetailViewModel(transaction: transaction)
    }

    var body: some View {
        List {
            Section("Transaction") {
                LabeledContent("Name", value: viewModel.transaction.name)
                LabeledContent("Amount", value: viewModel.formattedAmount)
                LabeledContent("Currency", value: viewModel.transaction.currency)
            }
            Section("Details") {
                LabeledContent("Category", value: viewModel.category)
                LabeledContent("Merchant", value: viewModel.transaction.merchant)
                LabeledContent("Card", value: viewModel.transaction.card)
                LabeledContent("Date", value: viewModel.formattedDate)
            }
        }
        .navigationTitle(viewModel.transaction.name)
        .onAppear {
            logger.info(
                "Displayed transaction detail",
                metadata: [
                    "transactionID": "\(viewModel.transaction.id.uuidString)",
                    "merchant": "\(viewModel.transaction.merchant)",
                    "category": "\(viewModel.transaction.category.rawValue)"
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
