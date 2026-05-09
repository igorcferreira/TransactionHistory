//
//  OnboardingCoordinatorViewModel.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 09/05/2026.
//

import Foundation

@Observable
@MainActor
final class OnboardingCoordinatorViewModel {
    enum Page: Int, Hashable {
        case welcome
        case notifications
    }

    var path: [Page] = []

    func showNotificationPermission() {
        path.append(.notifications)
    }
}
