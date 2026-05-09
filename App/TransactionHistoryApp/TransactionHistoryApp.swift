//
//  TransactionHistoryAppApp.swift
//  TransactionHistoryApp
//
//  Created by Igor Ferreira on 12/03/2026.
//

import AppIntents
import CloudKit
import Scout
import SwiftData
import SwiftUI
import TransactionHistory
import UserNotifications

@main
struct TransactionHistoryApp: App {
    private let dataStorage: DataStorage
    private let notificationDelegate: NotificationDelegate
    private let notificationRouter = NotificationRouter()

    init() {
        TransactionHistoryProvider.updateAppShortcutParameters()
        Self.setupLogger()
        self.dataStorage = DataStorage()

        let delegate = NotificationDelegate()
        self.notificationDelegate = delegate
        UNUserNotificationCenter.current().delegate = delegate
        NotificationService().registerCategories()

        delegate.onSetCategoryAction = { [notificationRouter] transactionID in
            notificationRouter.pendingCategoryTransactionID = transactionID
        }
        delegate.onShowDetail = { [notificationRouter] transactionID in
            notificationRouter.pendingDetailTransactionID = transactionID
        }
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .notificationRouter(notificationRouter)
        }
        .modelContainer(dataStorage.sharedModelContainer)
    }
}

extension TransactionHistoryApp {
    private static func setupLogger() {
        // Scout.setup() will bootstrap both LoggingSystem and MetricsSystem.
        // Mark them as externally bootstrapped to prevent lazy factory
        // methods from racing with Scout's async setup.
        AppLogger.prepareForExternalBootstrap()
        AppMetrics.prepareForExternalBootstrap()
        let container = CKContainer(
            identifier: "iCloud.dev.igorcferreira.TransactionHistoryApp"
        )
        try? Scout.setup(container: container)
    }
}
