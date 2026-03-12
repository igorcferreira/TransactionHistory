//
//  Transaction.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import Foundation
import SwiftData

@Model
public final class CardTransaction: Identifiable {
    public var id: UUID = UUID()
    public var name: String = ""
    public var ammount: String = ""
    public var merchant: String = ""
    public var card: String = ""
    public var createdAt: Date = Date()

    init(
        id: UUID = UUID(),
        name: String,
        ammount: String,
        merchant: String,
        card: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.ammount = ammount
        self.merchant = merchant
        self.card = card
        self.createdAt = createdAt
    }
}
