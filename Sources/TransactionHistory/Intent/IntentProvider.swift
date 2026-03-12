//
//  IntentProvider.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import Foundation
import AppIntents

nonisolated
public struct TransactionHistoryProvider: AppShortcutsProvider, Sendable {
    @AppShortcutsBuilder
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CreateTransactionIntent(),
            phrases: [
                "Register a purchase using \(.applicationName)",
                "Log a transaction on \(.applicationName)",
            ],
            shortTitle: "Register a purchase",
            systemImageName: "wallet.bifold.fill"
        )
    }

    public init() {}
}
