//
//  CreateTransactionViewTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 19/03/2026.
//
import Foundation
import Testing
import ViewInspector
import SwiftUI
@testable import TransactionHistory

@Suite("CreateTransactionView - Form Controls")
@MainActor
struct CreateTransactionViewTests {
    init() {
        _ = TestBootstrap.appLogger
    }

    // MARK: - Form fields

    @Test("Name text field is present")
    func nameFieldPresent() throws {
        // GIVEN a CreateTransactionView
        let view = CreateTransactionView()
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN a text field with 'Name' label exists
        _ = try inspected.find(
            ViewType.TextField.self,
            where: { try $0.labelView().text().string() == "Name" }
        )
    }

    @Test("Merchant text field is present")
    func merchantFieldPresent() throws {
        // GIVEN a CreateTransactionView
        let view = CreateTransactionView()
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN a text field with 'Merchant' label exists
        _ = try inspected.find(
            ViewType.TextField.self,
            where: { try $0.labelView().text().string() == "Merchant" }
        )
    }

    @Test("Amount text field is present with '0.00' placeholder")
    func amountFieldPresent() throws {
        // GIVEN a CreateTransactionView
        let view = CreateTransactionView()
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN a text field with '0.00' label exists
        _ = try inspected.find(
            ViewType.TextField.self,
            where: { try $0.labelView().text().string() == "0.00" }
        )
    }

    @Test("Card text field is present")
    func cardFieldPresent() throws {
        // GIVEN a CreateTransactionView
        let view = CreateTransactionView()
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN a text field with 'Card' label exists
        _ = try inspected.find(
            ViewType.TextField.self,
            where: { try $0.labelView().text().string() == "Card" }
        )
    }

    // MARK: - Currency picker

    @Test("Currency picker is present")
    func currencyPickerPresent() throws {
        // GIVEN a CreateTransactionView
        let view = CreateTransactionView()
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN a picker labeled 'Currency' exists
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == "Currency" }
        )
    }

    // MARK: - Custom date toggle

    @Test("Custom Date toggle is present")
    func customDateTogglePresent() throws {
        // GIVEN a CreateTransactionView
        let view = CreateTransactionView()
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN a toggle labeled 'Custom Date' exists
        _ = try inspected.find(ViewType.Toggle.self)
    }

    // MARK: - Section headers

    @Test("Transaction section header is present")
    func transactionSectionPresent() throws {
        // GIVEN a CreateTransactionView
        let view = CreateTransactionView()
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN a 'Transaction' section header is present
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == "Transaction" }
        )
    }

    @Test("Amount section header is present")
    func amountSectionPresent() throws {
        // GIVEN a CreateTransactionView
        let view = CreateTransactionView()
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN an 'Amount' section header is present
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == "Amount" }
        )
    }

    @Test("Details section header is present")
    func detailsSectionPresent() throws {
        // GIVEN a CreateTransactionView
        let view = CreateTransactionView()
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN a 'Details' section header is present
        _ = try inspected.find(
            ViewType.Text.self,
            where: { try $0.string() == "Details" }
        )
    }
}
