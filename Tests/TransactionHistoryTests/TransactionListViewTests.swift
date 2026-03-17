//
//  TransactionListViewTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import Foundation
import Testing
import ViewInspector
import SwiftUI
import SwiftData
@testable import TransactionHistory

@Suite("TransactionListView - Search and Order")
@MainActor
struct TransactionListViewTests {

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

    /// Hosts a view via ViewHosting so @Query can resolve, then inspects it.
    /// The `function` parameter must match between host and inspect calls
    /// so ViewInspector shares the medium (environment context).
    private static func inspectHosted<V: View>(
        _ view: V,
        function: String = #function
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        ViewHosting.host(view: view, function: function)
        return try view.inspect(function: function)
    }

    /// Extracts the transaction name from each row in rendered order.
    /// Each row is a Button wrapping a ShortTransactionView whose first
    /// Text child is the transaction name.
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
    /// The second Text in each ShortTransactionView is the merchant.
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

    // MARK: - Search field controls

    @Test("Search field is present and initially empty")
    func searchFieldInitiallyEmpty() throws {
        // GIVEN a TransactionListView with default state
        let view = TransactionListView()
        // WHEN inspecting the view
        let inspected = try view.inspect()
        let textField = try inspected.find(ViewType.TextField.self)
        // THEN the search field exists and is empty
        let input = try textField.input()
        #expect(input.isEmpty)
    }

    @Test("Search field has 'Search by merchant' placeholder")
    func searchFieldPlaceholder() throws {
        // GIVEN a TransactionListView
        let view = TransactionListView()
        // WHEN inspecting the search field label
        let inspected = try view.inspect()
        let textField = try inspected.find(ViewType.TextField.self)
        let label = try textField.labelView().text().string()
        // THEN the placeholder reads "Search by merchant"
        #expect(label == "Search by merchant")
    }

    @Test("Search field accepts user input")
    func searchFieldAcceptsInput() throws {
        // GIVEN a TransactionListView with an empty search field
        let view = TransactionListView()
        let inspected = try view.inspect()
        let textField = try inspected.find(ViewType.TextField.self)
        // WHEN the user types a search query
        try textField.setInput("Coffee")
        // THEN the text field reflects the new input
        let input = try textField.input()
        #expect(input == "Coffee")
    }

    // MARK: - Sort picker controls

    @Test("Sort picker is present with Newest and Oldest options")
    func sortPickerOptions() throws {
        // GIVEN a TransactionListView
        let view = TransactionListView()
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN both sort options are present
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == "Newest First" }
        )
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == "Oldest First" }
        )
    }

    @Test("Transaction list is present with expected identifier")
    func transactionListPresent() throws {
        // GIVEN a TransactionListView
        let view = TransactionListView()
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN a view with ID "transaction_list" exists
        _ = try inspected.find(viewWithId: "transaction_list")
    }

    // MARK: - Search filtering (cell content validation)
    // ViewHosting requires NSHostingController (macOS only).
    #if os(macOS)

    @Test("Empty search renders all transactions with exact names and merchants")
    func emptySearchRendersAllContent() throws {
        // GIVEN "Morning Latte" at Coffee Corner (today)
        //   and "USB Cable" at TechStore (yesterday)
        let container = try Self.makeContainer()
        try Self.makeTwoDayFixture(in: container)
        let view = TransactionListGroupView(search: "")
            .modelContainer(container)
        // WHEN hosting and inspecting
        let inspected = try Self.inspectHosted(view)
        defer { ViewHosting.expel() }
        // THEN exactly these two transaction names appear (any order, same day uncertain)
        let names = try Self.renderedTransactionNames(from: inspected)
        #expect(Set(names) == Set(["Morning Latte", "USB Cable"]))
        // AND exactly these two merchants appear
        let merchants = try Self.renderedMerchantNames(from: inspected)
        #expect(Set(merchants) == Set(["Coffee Corner", "TechStore"]))
    }

    @Test("Search 'Coffee' shows only Coffee Corner cell, excludes TechStore")
    func searchShowsOnlyCoffeeContent() throws {
        // GIVEN Coffee Corner and TechStore transactions
        let container = try Self.makeContainer()
        try Self.makeTwoDayFixture(in: container)
        let view = TransactionListGroupView(search: "Coffee")
            .modelContainer(container)
        // WHEN hosting and inspecting with search "Coffee"
        let inspected = try Self.inspectHosted(view)
        defer { ViewHosting.expel() }
        // THEN only "Morning Latte" appears as a cell name
        let names = try Self.renderedTransactionNames(from: inspected)
        #expect(names == ["Morning Latte"])
        // AND "USB Cable" is NOT rendered
        #expect(!names.contains("USB Cable"))
        // AND every rendered merchant contains the search term "Coffee"
        let merchants = try Self.renderedMerchantNames(from: inspected)
        #expect(merchants == ["Coffee Corner"])
        for merchant in merchants {
            #expect(merchant.localizedCaseInsensitiveContains("Coffee"))
        }
    }

    @Test("Search 'Tech' shows only TechStore cell, excludes Coffee Corner")
    func searchShowsOnlyTechContent() throws {
        // GIVEN Coffee Corner and TechStore transactions
        let container = try Self.makeContainer()
        try Self.makeTwoDayFixture(in: container)
        let view = TransactionListGroupView(search: "Tech")
            .modelContainer(container)
        // WHEN hosting and inspecting with search "Tech"
        let inspected = try Self.inspectHosted(view)
        defer { ViewHosting.expel() }
        // THEN only "USB Cable" appears
        let names = try Self.renderedTransactionNames(from: inspected)
        #expect(names == ["USB Cable"])
        // AND "Morning Latte" is NOT rendered
        #expect(!names.contains("Morning Latte"))
        // AND every rendered merchant contains the search term "Tech"
        let merchants = try Self.renderedMerchantNames(from: inspected)
        #expect(merchants == ["TechStore"])
        for merchant in merchants {
            #expect(merchant.localizedCaseInsensitiveContains("Tech"))
        }
    }

    @Test("Search with no match renders no cells, excludes all transactions")
    func searchNoMatchRendersZeroCells() throws {
        // GIVEN Coffee Corner and TechStore transactions
        let container = try Self.makeContainer()
        try Self.makeTwoDayFixture(in: container)
        let view = TransactionListGroupView(search: "NonExistent")
            .modelContainer(container)
        // WHEN hosting and inspecting with a non-matching search
        let inspected = try Self.inspectHosted(view)
        defer { ViewHosting.expel() }
        // THEN no transaction cells appear
        let names = try Self.renderedTransactionNames(from: inspected)
        #expect(names == [])
        // AND specifically neither transaction is rendered
        #expect(!names.contains("Morning Latte"))
        #expect(!names.contains("USB Cable"))
        // AND no section headers are rendered
        let headers = try Self.renderedSectionHeaders(from: inspected)
        #expect(headers == [])
    }

    @Test("Case-insensitive search shows matching cell, excludes non-matching")
    func searchCaseInsensitiveContent() throws {
        // GIVEN a "Coffee Corner" and "TechStore" merchant
        let container = try Self.makeContainer()
        try Self.makeTwoDayFixture(in: container)
        let view = TransactionListGroupView(search: "coffee")
            .modelContainer(container)
        // WHEN searching with lowercase "coffee"
        let inspected = try Self.inspectHosted(view)
        defer { ViewHosting.expel() }
        // THEN only "Morning Latte" appears
        let names = try Self.renderedTransactionNames(from: inspected)
        #expect(names == ["Morning Latte"])
        // AND "USB Cable" is NOT rendered
        #expect(!names.contains("USB Cable"))
        // AND the merchant matches case-insensitively
        let merchants = try Self.renderedMerchantNames(from: inspected)
        #expect(merchants == ["Coffee Corner"])
        for merchant in merchants {
            #expect(merchant.localizedCaseInsensitiveContains("coffee"))
        }
    }

    @Test("Partial search 'Coff' shows matching cell, excludes non-matching")
    func searchPartialContent() throws {
        // GIVEN "Coffee Corner" and "TechStore"
        let container = try Self.makeContainer()
        try Self.makeTwoDayFixture(in: container)
        let view = TransactionListGroupView(search: "Coff")
            .modelContainer(container)
        // WHEN searching with partial text "Coff"
        let inspected = try Self.inspectHosted(view)
        defer { ViewHosting.expel() }
        // THEN only "Morning Latte" appears
        let names = try Self.renderedTransactionNames(from: inspected)
        #expect(names == ["Morning Latte"])
        // AND "USB Cable" is NOT rendered
        #expect(!names.contains("USB Cable"))
        // AND the rendered merchant matches the partial search
        let merchants = try Self.renderedMerchantNames(from: inspected)
        #expect(merchants == ["Coffee Corner"])
        for merchant in merchants {
            #expect(merchant.localizedCaseInsensitiveContains("Coff"))
        }
    }

    #endif

}
