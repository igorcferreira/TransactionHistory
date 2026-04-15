//
//  AppCoordinatorViewModel.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 15/04/2026.
//

import Foundation

/// Manages tab selection state for the root tab-based coordinator.
@Observable
@MainActor
final class AppCoordinatorViewModel {
    /// Available tabs in the app.
    enum AppTab: Int, Hashable {
        case transactions
        case spending
    }

    /// The currently selected tab.
    var selectedTab: AppTab = .transactions
}
