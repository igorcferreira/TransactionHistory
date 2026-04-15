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
@testable import TransactionHistory

@Suite("TransactionListView - Search and Order")
@MainActor
struct TransactionListViewTests {
    init() {
        _ = TestBootstrap.appLogger
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

    @Test("Empty transaction list shows empty state")
    func transactionListEmpty() throws {
        // GIVEN a TransactionListView with no data
        let view = TransactionListView()
        // WHEN inspecting the view
        let inspected = try view.inspect()
        // THEN the empty state is shown
        _ = try inspected.find(ViewType.ContentUnavailableView.self)
    }

}
