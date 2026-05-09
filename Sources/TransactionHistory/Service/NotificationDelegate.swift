//
//  NotificationDelegate.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 09/05/2026.
//

import Foundation
import Logging
import UserNotifications

public final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, Sendable {
    private let logger: Logger
    // nonisolated(unsafe) because closures are only set once at app launch
    // before any notification callbacks fire.
    nonisolated(unsafe) public var onSetCategoryAction: (@MainActor @Sendable (UUID) -> Void)?
    nonisolated(unsafe) public var onShowDetail: (@MainActor @Sendable (UUID) -> Void)?

    public init(logger: Logger? = nil) {
        self.logger = logger ?? AppLogger.defaultLogger
        super.init()
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([])
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping @Sendable () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        guard let idString = userInfo[NotificationService.transactionIDKey] as? String,
              let transactionID = UUID(uuidString: idString) else {
            logger.debug(
                "Notification response ignored",
                metadata: ["action": "\(response.actionIdentifier)"]
            )
            completionHandler()
            return
        }

        let actionID = response.actionIdentifier

        switch actionID {
        case NotificationService.setCategoryActionIdentifier:
            logger.info(
                "Set category action received",
                metadata: ["transactionID": "\(transactionID.uuidString)"]
            )
            let action = onSetCategoryAction
            DispatchQueue.main.async {
                action?(transactionID)
                completionHandler()
            }

        case UNNotificationDefaultActionIdentifier:
            logger.info(
                "Notification tapped, navigating to detail",
                metadata: ["transactionID": "\(transactionID.uuidString)"]
            )
            let action = onShowDetail
            DispatchQueue.main.async {
                action?(transactionID)
                completionHandler()
            }

        default:
            logger.debug(
                "Unhandled notification action",
                metadata: ["action": "\(actionID)"]
            )
            completionHandler()
        }
    }
}
