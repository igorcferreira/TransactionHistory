//
//  NotificationPermissionViewModelTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 09/05/2026.
//

import Foundation
import Testing
@testable import TransactionHistory

@Suite("NotificationPermissionViewModel")
struct NotificationPermissionViewModelTests {

    @Test("isRequesting is false by default")
    @MainActor
    func isRequestingDefaultsFalse() {
        // GIVEN a freshly created view model
        let viewModel = NotificationPermissionViewModel()
        // THEN isRequesting is false
        #expect(!viewModel.isRequesting)
    }

    @Test("isRequesting is false after requestPermission completes")
    @MainActor
    func isRequestingResetAfterRequest() async {
        // GIVEN a view model
        let viewModel = NotificationPermissionViewModel()
        // WHEN requesting permission (will succeed or fail depending on test host)
        await viewModel.requestPermission()
        // THEN isRequesting is reset to false
        #expect(!viewModel.isRequesting)
    }
}
