//
//  TransactionGroup.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import Foundation

/// A group of transactions sharing the same calendar date.
struct TransactionGroup: Identifiable {
    let date: Date
    let transactions: [CardTransaction]

    var id: Date { date }
}
