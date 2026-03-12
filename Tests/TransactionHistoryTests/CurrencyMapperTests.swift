//
//  CurrencyMapperTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import Foundation
import Testing
@testable import TransactionHistory

@Suite("CurrencyMapper")
struct CurrencyMapperTests {

    // MARK: - Known currency symbols

    @Test("Parses USD from dollar sign")
    func parseUSD() {
        // GIVEN a US dollar formatted string
        let input = "$3.14"
        // WHEN parsing
        let result = CurrencyMapper.parse(input)
        // THEN it returns USD with the correct value
        #expect(result?.code == "USD")
        #expect(result?.value == 3.14)
    }

    @Test("Parses BRL from R$ symbol with comma decimal")
    func parseBRL() {
        // GIVEN a Brazilian real formatted string with comma as decimal separator
        let input = "R$3,14"
        // WHEN parsing
        let result = CurrencyMapper.parse(input)
        // THEN it returns BRL with the correct value
        #expect(result?.code == "BRL")
        #expect(result?.value == 3.14)
    }

    @Test("Parses EUR from euro sign")
    func parseEUR() {
        // GIVEN a euro formatted string
        let input = "€3.14"
        // WHEN parsing
        let result = CurrencyMapper.parse(input)
        // THEN it returns EUR with the correct value
        #expect(result?.code == "EUR")
        #expect(result?.value == 3.14)
    }

    @Test("Parses GBP with grouping separator")
    func parseGBP() {
        // GIVEN a British pound formatted string with thousands grouping
        let input = "£1,234.56"
        // WHEN parsing
        let result = CurrencyMapper.parse(input)
        // THEN it returns GBP with the correct value
        #expect(result?.code == "GBP")
        #expect(result?.value == 1234.56)
    }

    @Test("Parses JPY from yen sign")
    func parseJPY() {
        // GIVEN a Japanese yen formatted string
        let input = "¥100"
        // WHEN parsing
        let result = CurrencyMapper.parse(input)
        // THEN it returns a yen-based currency with the correct value
        let yenCodes = ["JPY", "CNY"]
        #expect(yenCodes.contains(result?.code ?? ""))
        #expect(result?.value == 100.0)
    }

    // MARK: - Fallback (no currency symbol)

    @Test("Falls back to current locale currency for plain number with dot decimal")
    func parsePlainNumberDot() {
        // GIVEN a plain number string without a currency symbol
        let input = "3.14"
        // WHEN parsing
        let result = CurrencyMapper.parse(input)
        // THEN it returns the current locale's currency with the correct value
        let expectedCode = Locale.current.currency?.identifier ?? "USD"
        #expect(result?.code == expectedCode)
        #expect(result?.value == 3.14)
    }

    @Test("Falls back to current locale currency for plain number with comma decimal")
    func parsePlainNumberComma() {
        // GIVEN a plain number string using comma as decimal separator
        let input = "3,14"
        // WHEN parsing
        let result = CurrencyMapper.parse(input)
        // THEN it returns a value (interpretation depends on locale)
        #expect(result != nil)
        let expectedCode = Locale.current.currency?.identifier ?? "USD"
        #expect(result?.code == expectedCode)
    }

    // MARK: - Invalid input

    @Test("Returns nil for empty string")
    func parseEmpty() {
        // GIVEN an empty string
        // WHEN parsing
        let result = CurrencyMapper.parse("")
        // THEN it returns nil
        #expect(result == nil)
    }

    @Test("Returns nil for whitespace-only string")
    func parseWhitespace() {
        // GIVEN a whitespace-only string
        // WHEN parsing
        let result = CurrencyMapper.parse("   ")
        // THEN it returns nil
        #expect(result == nil)
    }

    @Test("Returns nil for non-numeric garbage")
    func parseGarbage() {
        // GIVEN a string with no numeric content
        // WHEN parsing
        let result = CurrencyMapper.parse("abc")
        // THEN it returns nil
        #expect(result == nil)
    }
}
