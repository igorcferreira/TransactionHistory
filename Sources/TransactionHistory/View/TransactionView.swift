//
//  TransactionView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import SwiftUI

struct ShortTransactionView: View {
    let transaction: CardTransaction

    var body: some View {
        VStack(alignment: .leading) {
            Text(transaction.name)
                .bold()
            Text(transaction.formattedAmount)
        }
    }
}

#Preview {
    ShortTransactionView(transaction: .init(
        name: "Transaction Mock",
        currency: "EUR",
        amount: 12.34,
        merchant: "A nice merchant",
        card: "Virtual Card"
    ))
}
