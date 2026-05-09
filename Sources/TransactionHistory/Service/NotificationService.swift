//
//  NotificationService.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 09/05/2026.
//

import Foundation
import Logging
import UserNotifications

// UNUserNotificationCenter is thread-safe but not annotated as Sendable.
public struct NotificationService: @unchecked Sendable {
    static let categoryIdentifier = "TRANSACTION_CREATED"
    static let setCategoryActionIdentifier = "SET_CATEGORY"
    static let transactionIDKey = "transactionID"

    private let center: UNUserNotificationCenter?
    private let logger: Logger

    /// - Parameter center: Pass `nil` (default) to use `.current()` lazily at
    ///   call time. This avoids a crash in package-test runners where no app
    ///   bundle exists and `UNUserNotificationCenter.current()` throws.
    public init(
        center: UNUserNotificationCenter? = nil,
        logger: Logger? = nil
    ) {
        self.center = center
        self.logger = logger ?? AppLogger.defaultLogger
    }

    private var resolvedCenter: UNUserNotificationCenter {
        center ?? .current()
    }

    /// Registers the notification category with a "Set Category" action.
    public func registerCategories() {
        let setCategoryAction = UNNotificationAction(
            identifier: Self.setCategoryActionIdentifier,
            title: String(localized: "Set Category"),
            options: .foreground
        )
        let category = UNNotificationCategory(
            identifier: Self.categoryIdentifier,
            actions: [setCategoryAction],
            intentIdentifiers: [],
            options: []
        )
        resolvedCenter.setNotificationCategories([category])
        logger.debug("Registered notification categories")
    }

    /// Requests notification authorization from the user.
    @discardableResult
    public func requestAuthorization() async throws -> Bool {
        let granted = try await resolvedCenter.requestAuthorization(
            options: [.alert, .badge, .sound]
        )
        logger.info(
            "Notification authorization result",
            metadata: ["granted": "\(granted)"]
        )
        return granted
    }

    /// Returns the current notification authorization status.
    public func authorizationStatus() async -> UNAuthorizationStatus {
        await resolvedCenter.notificationSettings().authorizationStatus
    }

    /// Posts a local notification for a transaction created in the background.
    public func postTransactionCreated(
        name: String,
        merchant: String,
        formattedAmount: String,
        transactionID: UUID
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Transaction Recorded")

        if merchant.isEmpty {
            content.body = String(localized: "\(formattedAmount) recorded. Tap to set a category.")
        } else {
            content.body = String(localized: "\(merchant) — \(formattedAmount). Tap to set a category.")
        }

        content.sound = .default
        content.categoryIdentifier = Self.categoryIdentifier
        content.userInfo = [Self.transactionIDKey: transactionID.uuidString]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: transactionID.uuidString,
            content: content,
            trigger: trigger
        )

        try await resolvedCenter.add(request)
        logger.info(
            "Posted transaction notification",
            metadata: ["transactionID": "\(transactionID.uuidString)"]
        )
    }
}
