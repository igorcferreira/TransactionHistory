//
//  TransactionListViewSortTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
// ViewHosting requires NSHostingController, available on macOS only.
#if os(macOS)
import Foundation
import Testing
import ViewInspector
import SwiftUI
import SwiftData
@testable import TransactionHistory

@Suite("TransactionListView - Sort Order and Grouping")
@MainActor
struct TransactionListViewSortTests {
    init() {
        _ = TestBootstrap.appLogger
    }

    // MARK: - Helpers

    /// Creates an in-memory ModelContainer with no CloudKit sync.
    private static func makeContainer() throws -> ModelContainer {
        let schema = Schema([CardTransaction.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [config])
    }

    /// Inserts the given transactions into the container's main context.
    @discardableResult
    private static func seed(
        _ transactions: [CardTransaction],
        in container: ModelContainer
    ) throws -> [CardTransaction] {
        let context = container.mainContext
        for transaction in transactions {
            context.insert(transaction)
        }
        try context.save()
        return transactions
    }

    /// Builds a standard test data set: two merchants on different days.
    @discardableResult
    private static func makeTwoDayFixture(
        in container: ModelContainer
    ) throws -> (coffee: CardTransaction, tech: CardTransaction) {
        let calendar = Calendar.current
        let today = Date()
        // swiftlint:disable:next force_unwrapping
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let coffee = CardTransaction(
            name: "Morning Latte",
            currency: "EUR",
            amount: 4.50,
            merchant: "Coffee Corner",
            card: "Card",
            category: .generic,
            createdAt: today
        )
        let tech = CardTransaction(
            name: "USB Cable",
            currency: "EUR",
            amount: 12.99,
            merchant: "TechStore",
            card: "Card",
            category: .generic,
            createdAt: yesterday
        )
        try seed([coffee, tech], in: container)
        return (coffee, tech)
    }

    /// Hosts a view via ViewHosting so @Query can resolve.
    private static func inspectHosted<V: View>(
        _ view: V,
        function: String = #function
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        ViewHosting.host(view: view, function: function)
        return try view.inspect(function: function)
    }

    /// Extracts the transaction name from each row in rendered order.
    private static func renderedTransactionNames(
        from inspected: InspectableView<ViewType.ClassifiedView>
    ) throws -> [String] {
        let buttons = inspected.findAll(ViewType.Button.self)
        return try buttons.map { button in
            let texts = try button.labelView().findAll(ViewType.Text.self)
            return try texts[0].string()
        }
    }

    /// Extracts the merchant name from each row in rendered order.
    private static func renderedMerchantNames(
        from inspected: InspectableView<ViewType.ClassifiedView>
    ) throws -> [String] {
        let buttons = inspected.findAll(ViewType.Button.self)
        return try buttons.map { button in
            let texts = try button.labelView().findAll(ViewType.Text.self)
            return try texts[1].string()
        }
    }

    /// Extracts section header titles in rendered order.
    private static func renderedSectionHeaders(
        from inspected: InspectableView<ViewType.ClassifiedView>
    ) throws -> [String] {
        let sections = inspected.findAll(ViewType.Section.self)
        return try sections.map { section in
            try section.header().find(ViewType.Text.self).string()
        }
    }

    // MARK: - Sort order tests

    @Test("Reverse sort shows newest first with correct content")
    func reverseSortCellOrder() throws {
        // GIVEN "Morning Latte" (today) and "USB Cable" (yesterday)
        let container = try Self.makeContainer()
        try Self.makeTwoDayFixture(in: container)
        let view = TransactionListGroupView(
            search: "",
            sortOrder: .reverse
        ).modelContainer(container)
        // WHEN hosting and inspecting
        let inspected = try Self.inspectHosted(view)
        defer { ViewHosting.expel() }
        // THEN today's transaction appears first
        let names = try Self.renderedTransactionNames(from: inspected)
        #expect(names == ["Morning Latte", "USB Cable"])
        // AND merchants match the same order
        let merchants = try Self.renderedMerchantNames(from: inspected)
        #expect(merchants == ["Coffee Corner", "TechStore"])
        // AND section headers are newest first
        let headers = try Self.renderedSectionHeaders(from: inspected)
        #expect(headers == ["Today", "Yesterday"])
    }

    @Test("Forward sort shows oldest first with correct content")
    func forwardSortCellOrder() throws {
        // GIVEN "Morning Latte" (today) and "USB Cable" (yesterday)
        let container = try Self.makeContainer()
        try Self.makeTwoDayFixture(in: container)
        let view = TransactionListGroupView(
            search: "",
            sortOrder: .forward
        ).modelContainer(container)
        // WHEN hosting and inspecting
        let inspected = try Self.inspectHosted(view)
        defer { ViewHosting.expel() }
        // THEN yesterday's transaction appears first
        let names = try Self.renderedTransactionNames(from: inspected)
        #expect(names == ["USB Cable", "Morning Latte"])
        // AND merchants match the same order
        let merchants = try Self.renderedMerchantNames(from: inspected)
        #expect(merchants == ["TechStore", "Coffee Corner"])
        // AND section headers are oldest first
        let headers = try Self.renderedSectionHeaders(from: inspected)
        #expect(headers == ["Yesterday", "Today"])
    }

    // MARK: - Search + sort combined tests

    @Test("Search with forward sort shows matching cells oldest first")
    func searchWithForwardSortCellOrder() throws {
        // GIVEN three transactions: two Coffee merchants, one TechStore
        let container = try Self.makeContainer()
        let calendar = Calendar.current
        let today = Date()
        // swiftlint:disable:next force_unwrapping
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let morningLatte = CardTransaction(
            name: "Morning Latte",
            currency: "EUR",
            amount: 4.50,
            merchant: "Coffee Corner",
            card: "Card",
            category: .generic,
            createdAt: today
        )
        let afternoonCoffee = CardTransaction(
            name: "Afternoon Coffee",
            currency: "EUR",
            amount: 3.20,
            merchant: "Coffee Corner",
            card: "Card",
            category: .generic,
            createdAt: yesterday
        )
        let usbCable = CardTransaction(
            name: "USB Cable",
            currency: "EUR",
            amount: 12.99,
            merchant: "TechStore",
            card: "Card",
            category: .generic,
            createdAt: yesterday
        )
        try Self.seed(
            [morningLatte, afternoonCoffee, usbCable],
            in: container
        )
        let view = TransactionListGroupView(
            search: "Coffee",
            sortOrder: .forward
        ).modelContainer(container)
        // WHEN hosting and inspecting
        let inspected = try Self.inspectHosted(view)
        defer { ViewHosting.expel() }
        // THEN oldest Coffee transaction appears first
        let names = try Self.renderedTransactionNames(from: inspected)
        #expect(names == ["Afternoon Coffee", "Morning Latte"])
        // AND "USB Cable" is NOT rendered
        #expect(!names.contains("USB Cable"))
        // AND merchants are all Coffee Corner
        let merchants = try Self.renderedMerchantNames(from: inspected)
        #expect(merchants == ["Coffee Corner", "Coffee Corner"])
        // AND sections are oldest first
        let headers = try Self.renderedSectionHeaders(from: inspected)
        #expect(headers == ["Yesterday", "Today"])
    }

    @Test("Search with reverse sort shows matching cells newest first")
    func searchWithReverseSortCellOrder() throws {
        // GIVEN three transactions: two Coffee merchants, one TechStore
        let container = try Self.makeContainer()
        let calendar = Calendar.current
        let today = Date()
        // swiftlint:disable:next force_unwrapping
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let morningLatte = CardTransaction(
            name: "Morning Latte",
            currency: "EUR",
            amount: 4.50,
            merchant: "Coffee Corner",
            card: "Card",
            category: .generic,
            createdAt: today
        )
        let afternoonCoffee = CardTransaction(
            name: "Afternoon Coffee",
            currency: "EUR",
            amount: 3.20,
            merchant: "Coffee Corner",
            card: "Card",
            category: .generic,
            createdAt: yesterday
        )
        let usbCable = CardTransaction(
            name: "USB Cable",
            currency: "EUR",
            amount: 12.99,
            merchant: "TechStore",
            card: "Card",
            category: .generic,
            createdAt: yesterday
        )
        try Self.seed(
            [morningLatte, afternoonCoffee, usbCable],
            in: container
        )
        let view = TransactionListGroupView(
            search: "Coffee",
            sortOrder: .reverse
        ).modelContainer(container)
        // WHEN hosting and inspecting
        let inspected = try Self.inspectHosted(view)
        defer { ViewHosting.expel() }
        // THEN newest Coffee transaction appears first
        let names = try Self.renderedTransactionNames(from: inspected)
        #expect(names == ["Morning Latte", "Afternoon Coffee"])
        // AND "USB Cable" is NOT rendered
        #expect(!names.contains("USB Cable"))
        // AND sections are newest first
        let headers = try Self.renderedSectionHeaders(from: inspected)
        #expect(headers == ["Today", "Yesterday"])
    }

    // MARK: - Same-day grouping

    @Test("Same-day transactions appear in a single section")
    func sameDaySectionRowContent() throws {
        // GIVEN two transactions on the same day
        let container = try Self.makeContainer()
        let today = Date()
        let first = CardTransaction(
            name: "T1",
            currency: "EUR",
            amount: 1.00,
            merchant: "Shop A",
            card: "Card",
            category: .generic,
            createdAt: today
        )
        let second = CardTransaction(
            name: "T2",
            currency: "EUR",
            amount: 2.00,
            merchant: "Shop B",
            card: "Card",
            category: .generic,
            createdAt: today
        )
        try Self.seed([first, second], in: container)
        let view = TransactionListGroupView(search: "")
            .modelContainer(container)
        // WHEN hosting and inspecting
        let inspected = try Self.inspectHosted(view)
        defer { ViewHosting.expel() }
        // THEN there is exactly one section header
        let headers = try Self.renderedSectionHeaders(from: inspected)
        #expect(headers == ["Today"])
        // AND both transaction names appear
        let names = try Self.renderedTransactionNames(from: inspected)
        #expect(Set(names) == Set(["T1", "T2"]))
        // AND both merchants appear
        let merchants = try Self.renderedMerchantNames(from: inspected)
        #expect(Set(merchants) == Set(["Shop A", "Shop B"]))
    }
}
#endif
