//
//  CreateTransactionViewModel.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 15/03/2026.
//

import Foundation
import Logging
import SwiftData

/// ViewModel that manages form state and validation for creating a new transaction.
@Observable
@MainActor
final class CreateTransactionViewModel {

    // MARK: - Form fields

    var name: String = ""
    var merchant: String = ""
    var amountText: String = ""
    var currency: String = Locale.current.currency?.identifier ?? "EUR"
    var card: String = ""
    var date: Date?

    // MARK: - Common currencies

    /// Frequently-used ISO 4217 codes offered in the currency picker.
    static let commonCurrencies: [String] = {
        var codes = ["USD", "EUR", "GBP", "BRL", "JPY", "CAD", "AUD", "CHF"]
        if let locale = Locale.current.currency?.identifier,
           !codes.contains(locale) {
            codes.insert(locale, at: 0)
        }
        return codes
    }()

    /// Returns a display label with the currency symbol and code (e.g. "$ USD").
    /// Falls back to "CODE — Full Name" when no distinct symbol exists (e.g. "CHF — Swiss Franc").
    static func currencyLabel(for code: String) -> String {
        if let symbol = knownSymbols[code] {
            return "\(symbol) \(code)"
        }
        // No distinct symbol — show the localized name instead.
        let name = Locale.current.localizedString(forCurrencyCode: code)
        if let name { return "\(code) — \(name)" }
        return code
    }

    /// Narrow symbols for common currencies. Avoids locale-lookup inconsistencies
    /// (e.g. NumberFormatter returning "CA$" instead of "$" for CAD).
    private static let knownSymbols: [String: String] = [
        "USD": "$", "EUR": "€", "GBP": "£", "BRL": "R$",
        "JPY": "¥", "CAD": "C$", "AUD": "A$"
    ]

    // MARK: - Validation

    /// Whether the form has enough valid data to save.
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !merchant.trimmingCharacters(in: .whitespaces).isEmpty
            && !card.trimmingCharacters(in: .whitespaces).isEmpty
            && !currency.isEmpty
            && parsedAmount != nil
    }

    /// Parses `amountText` into a positive `Double`, returning `nil` on failure.
    private var parsedAmount: Double? {
        guard let value = Double(amountText), value > 0 else { return nil }
        return value
    }

    // MARK: - Persistence

    /// Creates the transaction via `CreateTransactionIntent`, which persists
    /// the record in the given context and donates the intent to Siri.
    func save(
        in container: ModelContainer,
        logger: Logger = AppLogger.makeLogger(label: "feature.createTransaction")
    ) async throws {
        guard let amount = parsedAmount else {
            logger.warning(
                "Blocked save because the amount is invalid",
                metadata: [
                    "hasName": "\(!name.trimmingCharacters(in: .whitespaces).isEmpty)",
                    "hasMerchant": "\(!merchant.trimmingCharacters(in: .whitespaces).isEmpty)",
                    "hasCard": "\(!card.trimmingCharacters(in: .whitespaces).isEmpty)"
                ]
            )
            return
        }

        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedMerchant = merchant.trimmingCharacters(in: .whitespaces)
        let formattedAmount = amount.formatted(.currency(code: currency))
        let trimmedCard = card.trimmingCharacters(in: .whitespaces)
        let resolvedDate = date ?? Date()

        logger.info(
            "Submitting manual transaction",
            metadata: [
                "merchant": "\(trimmedMerchant)",
                "currency": "\(currency)",
                "amount": "\(amount)",
                "hasCustomDate": "\(date != nil)"
            ]
        )

        // Create the transaction and donate it to Siri.
        try await CreateTransactionIntent.execute(
            name: trimmedName,
            merchant: trimmedMerchant,
            amount: formattedAmount,
            card: trimmedCard,
            date: resolvedDate,
            container: container,
            logger: logger
        )
    }
}
