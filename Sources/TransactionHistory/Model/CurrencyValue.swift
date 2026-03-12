//
//  CurrencyValue.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import Foundation

/// Holds a parsed currency amount: the ISO 4217 code and numeric value.
struct CurrencyValue: Sendable, Equatable {
    let code: String
    let value: Double
}
