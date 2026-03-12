//
//  TransactionListView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import Foundation
import SwiftUI
import SwiftData

public struct TransactionListView: View {
    @Query(
        sort: \CardTransaction.createdAt,
        order: .reverse
    ) var transactions: [CardTransaction]

    public init() {}

    public var body: some View {
        List(transactions) { transaction in
            ShortTransactionView(transaction: transaction)
        }
    }
}

#Preview {
    TransactionListView()
        .includingMocks()
}
