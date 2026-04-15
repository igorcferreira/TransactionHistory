//
//  TransactionListGroupContentViewTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 19/03/2026.
//
import Foundation
import Testing
import ViewInspector
import SwiftUI
@testable import TransactionHistory

@Suite("TransactionListGroupContentView - Grouped Transaction Rendering")
@MainActor
struct TransactionListGroupContentViewTests {
    init() {
        _ = TestBootstrap.appLogger
    }

    // MARK: - Helpers

    private func makeTransaction(
        name: String = "Test Transaction",
        merchant: String = "Test Merchant",
        amount: Double = 10.0,
        currency: String = "EUR",
        createdAt: Date = Date()
    ) -> CardTransaction {
        CardTransaction(
            name: name,
            currency: currency,
            amount: amount,
            merchant: merchant,
            card: "Card 1",
            category: .generic,
            createdAt: createdAt
        )
    }

    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    private var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: today)!
    }

    // MARK: - Empty state

    @Test("Empty groups renders empty state instead of list")
    func emptyGroups() throws {
        // GIVEN no transaction groups
        let view = TransactionListGroupContentView(groups: [])
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN the empty state is shown
        _ = try inspected.find(ViewType.ContentUnavailableView.self)
    }

    // MARK: - Section headers

    @Test("Renders 'Today' header for today's transactions")
    func todayHeader() throws {
        // GIVEN a group dated today
        let groups = [
            TransactionGroup(date: today, transactions: [makeTransaction()])
        ]
        let view = TransactionListGroupContentView(groups: groups)
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN a "Today" section header is present
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == "Today" }
        )
    }

    @Test("Renders 'Yesterday' header for yesterday's transactions")
    func yesterdayHeader() throws {
        // GIVEN a group dated yesterday
        let groups = [
            TransactionGroup(date: yesterday, transactions: [makeTransaction()])
        ]
        let view = TransactionListGroupContentView(groups: groups)
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN a "Yesterday" section header is present
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == "Yesterday" }
        )
    }

    // MARK: - Transaction rows

    @Test("Transaction name is rendered in the row")
    func transactionNameRendered() throws {
        // GIVEN a group with a named transaction
        let groups = [
            TransactionGroup(
                date: today,
                transactions: [makeTransaction(name: "Coffee Purchase")]
            )
        ]
        let view = TransactionListGroupContentView(groups: groups)
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN the transaction name appears
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == "Coffee Purchase" }
        )
    }

    @Test("Transaction merchant is rendered in the row")
    func transactionMerchantRendered() throws {
        // GIVEN a group with a transaction from a specific merchant
        let groups = [
            TransactionGroup(
                date: today,
                transactions: [makeTransaction(merchant: "Coffee Corner")]
            )
        ]
        let view = TransactionListGroupContentView(groups: groups)
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN the merchant name appears
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == "Coffee Corner" }
        )
    }

    // MARK: - Multiple groups

    @Test("Multiple groups render multiple sections")
    func multipleGroupsRender() throws {
        // GIVEN two groups for today and yesterday
        let groups = [
            TransactionGroup(date: today, transactions: [makeTransaction(name: "Today TX")]),
            TransactionGroup(date: yesterday, transactions: [makeTransaction(name: "Yesterday TX")])
        ]
        let view = TransactionListGroupContentView(groups: groups)
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN both section headers are present
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == "Today" }
        )
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == "Yesterday" }
        )
        // AND both transaction names are present
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == "Today TX" }
        )
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == "Yesterday TX" }
        )
    }

    // MARK: - List ID

    @Test("List has expected 'transaction_list' identifier")
    func listIdentifier() throws {
        // GIVEN a content view with any groups
        let view = TransactionListGroupContentView(
            groups: [TransactionGroup(date: today, transactions: [makeTransaction()])]
        )
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN the list can be found by its ID
        _ = try inspected.find(viewWithId: "transaction_list")
    }

    // MARK: - Tap callback

    @Test("Tapping a transaction row invokes the callback")
    func tapCallback() throws {
        // GIVEN a group with one transaction
        let transaction = makeTransaction(name: "Tappable TX")
        let groups = [
            TransactionGroup(date: today, transactions: [transaction])
        ]
        var tappedTransaction: CardTransaction?
        let view = TransactionListGroupContentView(
            groups: groups,
            onTransactionTapped: { tappedTransaction = $0 }
        )
        // WHEN tapping the transaction button
        let inspected = try view.inspect()
        let button = try inspected.find(ViewType.Button.self)
        try button.tap()
        // THEN the callback is invoked with the correct transaction
        #expect(tappedTransaction?.name == "Tappable TX")
    }
}
