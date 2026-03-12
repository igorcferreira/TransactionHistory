//
//  CreateTransactionIntent.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import Foundation
import AppIntents

struct CreateTransactionIntent: AppIntent, Sendable {
    static let title: LocalizedStringResource = "Create Transaction"
    static let supportedModes: IntentModes = .background

    func perform() async throws -> some ReturnsValue<String> {
        .result(value: "")
    }
}
