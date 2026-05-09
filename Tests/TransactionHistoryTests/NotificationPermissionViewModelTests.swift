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

    // Package test runners have no app bundle, so
    // UNUserNotificationCenter.current() crashes. Pass a
    // centerless NotificationService so methods gracefully no-op.
    private static var testService: NotificationService {
        NotificationService(center: nil)
    }

    @Test("isRequesting is false by default")
    @MainActor
    func isRequestingDefaultsFalse() {
        // GIVEN a freshly created view model
        let viewModel = NotificationPermissionViewModel(service: Self.testService)
        // THEN isRequesting is false
        #expect(!viewModel.isRequesting)
    }

    @Test("isRequesting is false after requestPermission completes")
    @MainActor
    func isRequestingResetAfterRequest() async {
        // GIVEN a view model with a no-op notification service
        let viewModel = NotificationPermissionViewModel(service: Self.testService)
        // WHEN requesting permission
        await viewModel.requestPermission()
        // THEN isRequesting is reset to false
        #expect(!viewModel.isRequesting)
    }
}
