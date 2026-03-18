//
//  TransactionHistoryAppApp.swift
//  TransactionHistoryApp
//
//  Created by Igor Ferreira on 12/03/2026.
//

import SwiftUI
import SwiftData
import TransactionHistory
import AppIntents

@main
struct TransactionHistoryApp: App {
    let dataStorage = DataStorage()

    init() {
        TransactionHistoryProvider.updateAppShortcutParameters()
        AppLogger.bootstrap()
    }

    var body: some Scene {
        WindowGroup {
            TransactionCoordinatorView()
        }
        .modelContainer(dataStorage.sharedModelContainer)
    }
}
