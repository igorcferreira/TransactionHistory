//
//  SpendingChartViewModelTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 15/04/2026.
//

import Foundation
import SwiftData
import Testing
@testable import TransactionHistory

@Suite("SpendingChartViewModel")
struct SpendingChartViewModelTests {

    // MARK: - Helpers

    private static func makeContainer() throws -> ModelContainer {
        let schema = Schema([CardTransaction.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [config])
    }

    private static func makeTransaction(
        name: String = "Test",
        currency: String = "EUR",
        amount: Double = 10.0,
        category: EntryCategory = .generic,
        date: Date = Date(),
        in context: ModelContext
    ) -> CardTransaction {
        let transaction = CardTransaction(
            name: name,
            currency: currency,
            amount: amount,
            merchant: "Merchant",
            card: "Card",
            category: category,
            createdAt: date
        )
        context.insert(transaction)
        return transaction
    }

    private static func date(year: Int, month: Int, day: Int = 1) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }

    // MARK: - aggregate

    @Test("aggregate with empty transactions produces empty results")
    @MainActor
    func aggregateEmptyTransactions() {
        // GIVEN a view model and no transactions
        let viewModel = SpendingChartViewModel()

        // WHEN aggregating empty list
        viewModel.aggregate(transactions: [])

        // THEN all outputs are empty and isEmpty is true
        #expect(viewModel.categoryTotals.isEmpty)
        #expect(viewModel.availableCurrencies.isEmpty)
        #expect(viewModel.selectedCurrency == "")
        #expect(viewModel.isEmpty)
    }

    @Test("isEmpty is false when there are category totals")
    @MainActor
    func isEmptyFalseWithData() throws {
        // GIVEN a transaction exists
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        _ = Self.makeTransaction(in: context)
        try context.save()

        let transactions = try context.fetch(FetchDescriptor<CardTransaction>())
        let viewModel = SpendingChartViewModel()

        // WHEN aggregating
        viewModel.aggregate(transactions: transactions)

        // THEN isEmpty is false
        #expect(!viewModel.isEmpty)
    }

    @Test("aggregate computes correct totals per category")
    @MainActor
    func aggregateCorrectTotals() throws {
        // GIVEN transactions in two categories
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        _ = Self.makeTransaction(amount: 20.0, category: .food, in: context)
        _ = Self.makeTransaction(amount: 30.0, category: .food, in: context)
        _ = Self.makeTransaction(amount: 15.0, category: .shopping, in: context)
        try context.save()

        let transactions = try context.fetch(FetchDescriptor<CardTransaction>())
        let viewModel = SpendingChartViewModel()

        // WHEN aggregating
        viewModel.aggregate(transactions: transactions)

        // THEN totals are correct and sorted descending
        #expect(viewModel.categoryTotals.count == 2)
        #expect(viewModel.categoryTotals[0].category == .food)
        #expect(viewModel.categoryTotals[0].total == 50.0)
        #expect(viewModel.categoryTotals[1].category == .shopping)
        #expect(viewModel.categoryTotals[1].total == 15.0)
    }

    @Test("aggregate computes correct percentages")
    @MainActor
    func aggregateCorrectPercentages() throws {
        // GIVEN transactions totaling 100
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        _ = Self.makeTransaction(amount: 75.0, category: .travel, in: context)
        _ = Self.makeTransaction(amount: 25.0, category: .health, in: context)
        try context.save()

        let transactions = try context.fetch(FetchDescriptor<CardTransaction>())
        let viewModel = SpendingChartViewModel()

        // WHEN aggregating
        viewModel.aggregate(transactions: transactions)

        // THEN percentages are correct
        let travelTotal = viewModel.categoryTotals.first { $0.category == .travel }
        let healthTotal = viewModel.categoryTotals.first { $0.category == .health }
        #expect(travelTotal?.percentage == 0.75)
        #expect(healthTotal?.percentage == 0.25)
    }

    @Test("single currency sets hasMultipleCurrencies to false")
    @MainActor
    func singleCurrencyNoMultiple() throws {
        // GIVEN transactions in a single currency
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        _ = Self.makeTransaction(currency: "EUR", in: context)
        try context.save()

        let transactions = try context.fetch(FetchDescriptor<CardTransaction>())
        let viewModel = SpendingChartViewModel()

        // WHEN aggregating
        viewModel.aggregate(transactions: transactions)

        // THEN hasMultipleCurrencies is false
        #expect(!viewModel.hasMultipleCurrencies)
        #expect(viewModel.selectedCurrency == "EUR")
    }

    @Test("multiple currencies defaults to most common")
    @MainActor
    func multipleCurrenciesDefaultsToMostCommon() throws {
        // GIVEN 3 EUR and 1 USD transactions
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        _ = Self.makeTransaction(currency: "EUR", in: context)
        _ = Self.makeTransaction(currency: "EUR", in: context)
        _ = Self.makeTransaction(currency: "EUR", in: context)
        _ = Self.makeTransaction(currency: "USD", in: context)
        try context.save()

        let transactions = try context.fetch(FetchDescriptor<CardTransaction>())
        let viewModel = SpendingChartViewModel()

        // WHEN aggregating
        viewModel.aggregate(transactions: transactions)

        // THEN EUR is selected and both currencies are available
        #expect(viewModel.hasMultipleCurrencies)
        #expect(viewModel.selectedCurrency == "EUR")
        #expect(viewModel.availableCurrencies.contains("EUR"))
        #expect(viewModel.availableCurrencies.contains("USD"))
    }

    @Test("changing selectedCurrency re-aggregates for that currency")
    @MainActor
    func changingCurrencyReaggregates() throws {
        // GIVEN mixed-currency transactions
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        _ = Self.makeTransaction(currency: "EUR", amount: 50.0, category: .food, in: context)
        _ = Self.makeTransaction(currency: "USD", amount: 30.0, category: .shopping, in: context)
        try context.save()

        let transactions = try context.fetch(FetchDescriptor<CardTransaction>())
        let viewModel = SpendingChartViewModel()

        // WHEN aggregating then switching to USD
        viewModel.aggregate(transactions: transactions)
        viewModel.selectedCurrency = "USD"
        viewModel.aggregate(transactions: transactions)

        // THEN only USD category totals appear
        #expect(viewModel.categoryTotals.count == 1)
        #expect(viewModel.categoryTotals[0].category == .shopping)
        #expect(viewModel.categoryTotals[0].total == 30.0)
        #expect(viewModel.categoryTotals[0].currency == "USD")
    }

    @Test("categories with no transactions are excluded")
    @MainActor
    func emptyCategoriesExcluded() throws {
        // GIVEN transactions only in .food
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        _ = Self.makeTransaction(category: .food, in: context)
        try context.save()

        let transactions = try context.fetch(FetchDescriptor<CardTransaction>())
        let viewModel = SpendingChartViewModel()

        // WHEN aggregating
        viewModel.aggregate(transactions: transactions)

        // THEN only food appears
        #expect(viewModel.categoryTotals.count == 1)
        #expect(viewModel.categoryTotals[0].category == .food)
    }

    @Test("formattedPercentage produces correct string")
    @MainActor
    func formattedPercentageCorrect() {
        // GIVEN a category total with 50% percentage
        let total = SpendingChartViewModel.CategoryTotal(
            category: .food,
            currency: "EUR",
            total: 50.0,
            percentage: 0.5
        )

        // THEN formatted percentage is "50%"
        #expect(total.formattedPercentage == "50%")
    }

    @Test("totals are sorted descending by amount")
    @MainActor
    func totalsSortedDescending() throws {
        // GIVEN transactions with varying amounts
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        _ = Self.makeTransaction(amount: 5.0, category: .health, in: context)
        _ = Self.makeTransaction(amount: 100.0, category: .travel, in: context)
        _ = Self.makeTransaction(amount: 50.0, category: .food, in: context)
        try context.save()

        let transactions = try context.fetch(FetchDescriptor<CardTransaction>())
        let viewModel = SpendingChartViewModel()

        // WHEN aggregating
        viewModel.aggregate(transactions: transactions)

        // THEN sorted descending
        let amounts = viewModel.categoryTotals.map(\.total)
        #expect(amounts == [100.0, 50.0, 5.0])
    }

    @Test("NaN amounts are excluded from aggregation")
    @MainActor
    func nanAmountsExcluded() throws {
        // GIVEN one valid and one NaN-amount transaction
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        _ = Self.makeTransaction(amount: 40.0, category: .food, in: context)
        _ = Self.makeTransaction(amount: .nan, category: .shopping, in: context)
        try context.save()

        let transactions = try context.fetch(FetchDescriptor<CardTransaction>())
        let viewModel = SpendingChartViewModel()

        // WHEN aggregating
        viewModel.aggregate(transactions: transactions)

        // THEN only the valid transaction is included
        #expect(viewModel.categoryTotals.count == 1)
        #expect(viewModel.categoryTotals[0].category == .food)
        #expect(viewModel.categoryTotals[0].total == 40.0)
        #expect(viewModel.categoryTotals[0].percentage == 1.0)
    }

    @Test("negative amounts are excluded from aggregation")
    @MainActor
    func negativeAmountsExcluded() throws {
        // GIVEN one positive and one negative transaction
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        _ = Self.makeTransaction(amount: 60.0, category: .travel, in: context)
        _ = Self.makeTransaction(amount: -20.0, category: .food, in: context)
        try context.save()

        let transactions = try context.fetch(FetchDescriptor<CardTransaction>())
        let viewModel = SpendingChartViewModel()

        // WHEN aggregating
        viewModel.aggregate(transactions: transactions)

        // THEN only the positive transaction appears
        #expect(viewModel.categoryTotals.count == 1)
        #expect(viewModel.categoryTotals[0].category == .travel)
        #expect(viewModel.categoryTotals[0].total == 60.0)
    }

    @Test("rebuildForSelectedCurrency updates totals without changing currency list")
    @MainActor
    func rebuildForSelectedCurrency() throws {
        // GIVEN mixed-currency transactions already aggregated
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        _ = Self.makeTransaction(currency: "EUR", amount: 50.0, category: .food, in: context)
        _ = Self.makeTransaction(currency: "EUR", amount: 20.0, category: .food, in: context)
        _ = Self.makeTransaction(currency: "USD", amount: 30.0, category: .shopping, in: context)
        try context.save()

        let transactions = try context.fetch(FetchDescriptor<CardTransaction>())
        let viewModel = SpendingChartViewModel()
        viewModel.aggregate(transactions: transactions)

        // WHEN switching currency and rebuilding
        viewModel.selectedCurrency = "USD"
        viewModel.rebuildForSelectedCurrency(transactions: transactions)

        // THEN totals reflect USD, currencies list unchanged
        #expect(viewModel.availableCurrencies == ["EUR", "USD"])
        #expect(viewModel.categoryTotals.count == 1)
        #expect(viewModel.categoryTotals[0].currency == "USD")
        #expect(viewModel.categoryTotals[0].total == 30.0)
    }
}
