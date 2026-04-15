//
//  AppCoordinatorViewModelTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 15/04/2026.
//

import Foundation
import Testing
@testable import TransactionHistory

@Suite("AppCoordinatorViewModel")
struct AppCoordinatorViewModelTests {

    @Test("default tab is transactions")
    @MainActor
    func defaultTabIsTransactions() {
        // GIVEN a fresh view model
        let viewModel = AppCoordinatorViewModel()

        // THEN the default tab is transactions
        #expect(viewModel.selectedTab == .transactions)
    }
}
