//
//  CreateTransactionViewModelTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 15/03/2026.
//

import Foundation
import SwiftData
import Testing
@testable import TransactionHistory

@Suite("CreateTransactionViewModel")
@MainActor
struct CreateTransactionViewModelTests {

    // MARK: - Helpers

    /// Returns a view model pre-filled with valid data so individual tests
    /// can clear one field at a time.
    private static func makeValidViewModel() -> CreateTransactionViewModel {
        let viewModel = CreateTransactionViewModel()
        viewModel.name = "Coffee"
        viewModel.merchant = "Coffee Corner"
        viewModel.amountText = "4.50"
        viewModel.currency = "EUR"
        viewModel.card = "Card 1"
        return viewModel
    }

    // MARK: - canSave validation

    @Test("canSave is false when name is empty")
    func canSaveFalseWhenNameEmpty() {
        // GIVEN a view model with an empty name
        let viewModel = Self.makeValidViewModel()
        viewModel.name = ""
        // THEN canSave is false
        #expect(!viewModel.canSave)
    }

    @Test("canSave is false when name is whitespace-only")
    func canSaveFalseWhenNameWhitespace() {
        // GIVEN a view model with a whitespace-only name
        let viewModel = Self.makeValidViewModel()
        viewModel.name = "   "
        // THEN canSave is false
        #expect(!viewModel.canSave)
    }

    @Test("canSave is false when merchant is empty")
    func canSaveFalseWhenMerchantEmpty() {
        // GIVEN a view model with an empty merchant
        let viewModel = Self.makeValidViewModel()
        viewModel.merchant = ""
        // THEN canSave is false
        #expect(!viewModel.canSave)
    }

    @Test("canSave is false when merchant is whitespace-only")
    func canSaveFalseWhenMerchantWhitespace() {
        // GIVEN a view model with a whitespace-only merchant
        let viewModel = Self.makeValidViewModel()
        viewModel.merchant = "   "
        // THEN canSave is false
        #expect(!viewModel.canSave)
    }

    @Test("canSave is false when card is empty")
    func canSaveFalseWhenCardEmpty() {
        // GIVEN a view model with an empty card
        let viewModel = Self.makeValidViewModel()
        viewModel.card = ""
        // THEN canSave is false
        #expect(!viewModel.canSave)
    }

    @Test("canSave is false when card is whitespace-only")
    func canSaveFalseWhenCardWhitespace() {
        // GIVEN a view model with a whitespace-only card
        let viewModel = Self.makeValidViewModel()
        viewModel.card = "   "
        // THEN canSave is false
        #expect(!viewModel.canSave)
    }

    @Test("canSave is false when amountText is not a number")
    func canSaveFalseWhenAmountInvalid() {
        // GIVEN a view model with non-numeric amount text
        let viewModel = Self.makeValidViewModel()
        viewModel.amountText = "abc"
        // THEN canSave is false
        #expect(!viewModel.canSave)
    }

    @Test("canSave is false when amountText is zero")
    func canSaveFalseWhenAmountZero() {
        // GIVEN a view model with zero amount
        let viewModel = Self.makeValidViewModel()
        viewModel.amountText = "0"
        // THEN canSave is false
        #expect(!viewModel.canSave)
    }

    @Test("canSave is false when amountText is negative")
    func canSaveFalseWhenAmountNegative() {
        // GIVEN a view model with a negative amount
        let viewModel = Self.makeValidViewModel()
        viewModel.amountText = "-5.00"
        // THEN canSave is false
        #expect(!viewModel.canSave)
    }

    @Test("canSave is true when all required fields are valid")
    func canSaveTrueWhenValid() {
        // GIVEN a view model with all valid fields
        let viewModel = Self.makeValidViewModel()
        // THEN canSave is true
        #expect(viewModel.canSave)
    }

    @Test("canSave is true regardless of date being nil")
    func canSaveTrueWithNilDate() {
        // GIVEN a view model with all valid fields and nil date
        let viewModel = Self.makeValidViewModel()
        viewModel.date = nil
        // THEN canSave is true
        #expect(viewModel.canSave)
    }

    @Test("canSave is true regardless of date being set")
    func canSaveTrueWithSetDate() {
        // GIVEN a view model with all valid fields and an explicit date
        let viewModel = Self.makeValidViewModel()
        viewModel.date = Date(timeIntervalSince1970: 1_000_000)
        // THEN canSave is true
        #expect(viewModel.canSave)
    }

    // MARK: - Default currency

    @Test("default currency matches the current locale")
    func defaultCurrencyMatchesLocale() {
        // GIVEN a new view model
        let viewModel = CreateTransactionViewModel()
        // THEN the currency matches the device locale (or USD fallback)
        let expected = Locale.current.currency?.identifier ?? "USD"
        #expect(viewModel.currency == expected)
    }

    // MARK: - Helpers (save tests)

    /// Creates an isolated in-memory ModelContext for save tests.
    private static func makeContext() throws -> ModelContext {
        let schema = Schema([CardTransaction.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    // MARK: - save (async, persists via CreateTransactionIntent)

    @Test("save with nil date uses current date for createdAt")
    func saveWithNilDateUsesNow() async throws {
        // GIVEN a valid view model with no date set and an isolated context
        let viewModel = Self.makeValidViewModel()
        viewModel.date = nil
        let context = try Self.makeContext()
        // WHEN saving
        let before = Date()
        try await viewModel.save(in: context)
        let after = Date()
        // THEN the transaction's createdAt is approximately now
        let transactions = try context.fetch(FetchDescriptor<CardTransaction>())
        #expect(transactions.count == 1)
        let createdAt = try #require(transactions.first?.createdAt)
        #expect(createdAt >= before && createdAt <= after)
    }

    @Test("save with explicit date uses that date for createdAt")
    func saveWithExplicitDate() async throws {
        // GIVEN a valid view model with an explicit date and an isolated context
        let viewModel = Self.makeValidViewModel()
        let explicitDate = Date(timeIntervalSince1970: 1_000_000)
        viewModel.date = explicitDate
        let context = try Self.makeContext()
        // WHEN saving
        try await viewModel.save(in: context)
        // THEN the transaction's createdAt matches the explicit date
        let transactions = try context.fetch(FetchDescriptor<CardTransaction>())
        #expect(transactions.count == 1)
        #expect(transactions.first?.createdAt == explicitDate)
    }

    @Test("save inserts a transaction with correct field values")
    func saveInsertsTransaction() async throws {
        // GIVEN a valid view model and an isolated context
        let viewModel = Self.makeValidViewModel()
        let context = try Self.makeContext()
        // WHEN saving
        try await viewModel.save(in: context)
        // THEN a transaction is inserted with matching values
        let transactions = try context.fetch(FetchDescriptor<CardTransaction>())
        let saved = try #require(transactions.first)
        #expect(saved.name == "Coffee")
        #expect(saved.merchant == "Coffee Corner")
        #expect(saved.amount == 4.50)
        #expect(saved.currency == "EUR")
        #expect(saved.card == "Card 1")
    }
}
