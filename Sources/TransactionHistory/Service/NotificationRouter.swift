//
//  NotificationRouter.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 09/05/2026.
//

import Foundation
import SwiftUI

/// Shared state that routes notification actions into the SwiftUI view hierarchy.
/// The NotificationDelegate writes to it; the AppCoordinatorView reads from it.
@Observable
public final class NotificationRouter: @unchecked Sendable {
    /// Notification tap → show the category picker sheet.
    @MainActor public var pendingCategoryTransactionID: UUID?
    /// Notification tap → navigate to the transaction detail.
    @MainActor public var pendingDetailTransactionID: UUID?

    public init() {}
}

private struct NotificationRouterKey: EnvironmentKey {
    static let defaultValue = NotificationRouter()
}

public extension EnvironmentValues {
    var notificationRouter: NotificationRouter {
        get { self[NotificationRouterKey.self] }
        set { self[NotificationRouterKey.self] = newValue }
    }
}

public extension View {
    func notificationRouter(_ router: NotificationRouter) -> some View {
        environment(\.notificationRouter, router)
    }
}
