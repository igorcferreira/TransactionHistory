//
//  ShortTransactionView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import SwiftUI

struct ShortTransactionView: View {
    let transaction: CardTransaction

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(transaction.name)
                    .bold()
                Text(transaction.merchant)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(transaction.formattedAmount)
            }
            Spacer()
            Text(transaction.createdAt, style: .time)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .id("transaction_\(transaction.id)")
    }
}

#Preview {
    ShortTransactionView(transaction: .init(
        name: "Transaction Mock",
        currency: "EUR",
        amount: 12.34,
        merchant: "A nice merchant",
        card: "Virtual Card",
        category: .generic
    ))
}
