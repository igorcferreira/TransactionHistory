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
            Text(transaction.ammount)
        }
    }
}

#Preview {
    ShortTransactionView(transaction: .init(
        name: "Transaction Mock",
        ammount: "€12.34",
        merchant: "A nice merchant",
        card: "Virtual Card"
    ))
}
