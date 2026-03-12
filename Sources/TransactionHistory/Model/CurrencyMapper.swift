//
//  CurrencyMapper.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import Foundation

/// Parses locale-formatted currency strings (e.g. "$3.14", "R$3,14", "€3.14")
/// into a `CurrencyValue` containing the ISO 4217 code and numeric value.
///
/// Uses Foundation's `Locale` database to dynamically resolve currency symbols,
/// so any currency known to the system is supported without hardcoding.
struct CurrencyMapper: Sendable {

    /// Each entry maps a currency symbol to a locale suitable for parsing
    /// and the corresponding ISO 4217 currency code.
    private struct SymbolEntry: Sendable {
        let symbol: String
        let locale: Locale
        let code: String
    }

    // Preferred ISO codes for ambiguous symbols shared by multiple currencies.
    private static let preferredCodes: [String: String] = [
        "$": "USD",
        "¥": "JPY",
        "kr": "SEK",
        "£": "GBP"
    ]

    // Built once — sorted longest symbol first so "R$" matches before "$".
    private let symbolTable: [SymbolEntry] = {
        var seen: [String: SymbolEntry] = [:]

        for identifier in Locale.availableIdentifiers {
            let locale = Locale(identifier: identifier)
            guard let code = locale.currency?.identifier,
                  let symbol = locale.currencySymbol,
                  !symbol.isEmpty else { continue }

            // Skip entries where the "symbol" is just the ISO code itself (e.g. "USD").
            if symbol == code { continue }

            if let existing = seen[symbol] {
                // Replace if the new entry matches the preferred code for this symbol.
                if let preferred = Self.preferredCodes[symbol], code == preferred {
                    seen[symbol] = SymbolEntry(symbol: symbol, locale: locale, code: code)
                }
                _ = existing
            } else {
                seen[symbol] = SymbolEntry(symbol: symbol, locale: locale, code: code)
            }
        }

        // Sort longest symbol first so multi-character symbols match before shorter ones.
        return seen.values.sorted { $0.symbol.count > $1.symbol.count }
    }()

    /// Parses a locale-formatted currency string into a `CurrencyValue`.
    ///
    /// - Parameter input: A string like "$3.14", "R$3,14", "€3.14", or a plain number "3.14".
    /// - Returns: A `CurrencyValue` with the detected ISO code and numeric value,
    ///   or `nil` if parsing fails entirely.
    func parse(_ input: String) -> CurrencyValue? {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        // Try to match a known currency symbol in the input.
        for entry in symbolTable {
            guard trimmed.contains(entry.symbol) else { continue }

            // Strip the symbol and try to parse the remaining numeric portion.
            let stripped = trimmed
                .replacingOccurrences(of: entry.symbol, with: "")
                .trimmingCharacters(in: .whitespaces)

            if let value = parseNumber(stripped, locale: entry.locale) {
                return CurrencyValue(code: entry.code, value: value)
            }
        }

        // No currency symbol found — treat as a plain number with the device locale's currency.
        return parseFallback(trimmed)
    }

    // MARK: - Private helpers

    /// Tries multiple strategies to parse a numeric string:
    /// the given locale, POSIX, and a comma-decimal locale as fallbacks.
    private func parseNumber(_ string: String, locale: Locale) -> Double? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        // Try the matched locale's decimal conventions first.
        formatter.locale = locale
        if let number = formatter.number(from: string) {
            return number.doubleValue
        }

        // Fallback to POSIX (dot decimal, comma grouping).
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if let number = formatter.number(from: string) {
            return number.doubleValue
        }

        // Fallback to a comma-decimal locale (e.g. "3,14" when the matched locale uses dots).
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.number(from: string)?.doubleValue
    }

    /// Fallback: parse a plain number string using the current locale's currency code.
    /// Tries the current locale first, then POSIX, then a comma-decimal locale (de_DE)
    /// to cover inputs like "3,14" on a dot-decimal system.
    private func parseFallback(_ string: String) -> CurrencyValue? {
        let currentLocale = Locale.current
        let code = currentLocale.currency?.identifier ?? "USD"

        // Try the current locale's decimal format, then POSIX.
        if let value = parseNumber(string, locale: currentLocale) {
            return CurrencyValue(code: code, value: value)
        }

        // Try a comma-decimal locale as a last resort.
        let commaLocale = Locale(identifier: "de_DE")
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = commaLocale
        if let value = formatter.number(from: string)?.doubleValue {
            return CurrencyValue(code: code, value: value)
        }

        return nil
    }
}
