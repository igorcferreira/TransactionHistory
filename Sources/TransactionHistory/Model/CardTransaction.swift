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
    
    #Index<CardTransaction>(
        [\.createdAt],
        [\.categoryRawType],
        [\.categoryRawType, \.createdAt],
        [\.currency],
        [\.currency, \.createdAt],
        [\.merchant],
        [\.merchant, \.createdAt],
    )
    
    public var id: UUID = UUID()
    public var name: String = ""
    public var currency: String = ""
    public var amount: Double = Double.nan
    public var merchant: String = ""
    public var card: String = ""
    public var createdAt: Date = Date()
    public var categoryRawType: String = EntryCategory.generic.rawValue
    
    @Transient
    public var category: EntryCategory {
        get { .init(rawValue: categoryRawType) ?? .generic }
        set { categoryRawType = newValue.rawValue }
    }

    /// Locale-formatted string combining currency and amount (e.g. "€12.34").
    var formattedAmount: String {
        amount.formatted(.currency(code: currency))
    }

    init(
        id: UUID = UUID(),
        name: String,
        currency: String,
        amount: Double,
        merchant: String,
        card: String,
        category: EntryCategory,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.currency = currency
        self.amount = amount
        self.merchant = merchant
        self.card = card
        self.createdAt = createdAt
    }
}
