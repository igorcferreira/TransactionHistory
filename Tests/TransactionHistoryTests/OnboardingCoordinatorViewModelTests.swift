//
//  OnboardingCoordinatorViewModelTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 09/05/2026.
//

import Foundation
import Testing
@testable import TransactionHistory

@Suite("OnboardingCoordinatorViewModel")
struct OnboardingCoordinatorViewModelTests {

    @Test("path starts empty, showing the welcome page")
    @MainActor
    func pathStartsEmpty() {
        // GIVEN a freshly created view model
        let viewModel = OnboardingCoordinatorViewModel()
        // THEN the path is empty (welcome is the root)
        #expect(viewModel.path.isEmpty)
    }

    @Test("showNotificationPermission pushes notifications page onto path")
    @MainActor
    func showNotificationPermissionPushesPage() {
        // GIVEN a view model at the welcome page
        let viewModel = OnboardingCoordinatorViewModel()
        // WHEN advancing to notification permission
        viewModel.showNotificationPermission()
        // THEN the path contains the notifications page
        #expect(viewModel.path == [.notifications])
    }
}
