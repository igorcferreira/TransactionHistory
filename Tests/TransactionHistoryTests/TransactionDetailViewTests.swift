//
//  TransactionDetailViewTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 19/03/2026.
//
import Foundation
import Testing
import ViewInspector
import SwiftUI
@testable import TransactionHistory

@Suite("TransactionDetailView - Detail Rendering")
@MainActor
struct TransactionDetailViewTests {
    init() {
        _ = TestBootstrap.appLogger
    }

    // MARK: - Helpers

    private func makeTransaction(
        name: String = "Coffee Purchase",
        currency: String = "EUR",
        amount: Double = 4.50,
        merchant: String = "Coffee Corner",
        card: String = "Virtual Card",
        category: EntryCategory = .generic
    ) -> CardTransaction {
        CardTransaction(
            name: name,
            currency: currency,
            amount: amount,
            merchant: merchant,
            card: card,
            category: category
        )
    }

    // MARK: - Field display

    @Test("Displays the transaction name")
    func displaysName() throws {
        // GIVEN a transaction with a known name
        let view = TransactionDetailView(
            transaction: makeTransaction(name: "Grocery Run")
        )
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN the name is rendered
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == "Grocery Run" }
        )
    }

    @Test("Displays the merchant")
    func displaysMerchant() throws {
        // GIVEN a transaction with a known merchant
        let view = TransactionDetailView(
            transaction: makeTransaction(merchant: "TechStore")
        )
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN the merchant is rendered
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == "TechStore" }
        )
    }

    @Test("Displays the card")
    func displaysCard() throws {
        // GIVEN a transaction with a known card
        let view = TransactionDetailView(
            transaction: makeTransaction(card: "Platinum Card")
        )
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN the card is rendered
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == "Platinum Card" }
        )
    }

    @Test("Displays the currency")
    func displaysCurrency() throws {
        // GIVEN a transaction with EUR currency
        let view = TransactionDetailView(
            transaction: makeTransaction(currency: "EUR")
        )
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN the currency code is rendered
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == "EUR" }
        )
    }

    @Test("Displays the formatted amount")
    func displaysFormattedAmount() throws {
        // GIVEN a transaction with a known amount
        let transaction = makeTransaction(currency: "EUR", amount: 12.34)
        let view = TransactionDetailView(transaction: transaction)
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN the formatted amount is rendered
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == transaction.formattedAmount }
        )
    }

    @Test("Displays the category")
    func displaysCategory() throws {
        // GIVEN a transaction with a known category
        let view = TransactionDetailView(
            transaction: makeTransaction(category: .generic)
        )
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN the category label is rendered
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == EntryCategory.generic.rawValue }
        )
    }
}
