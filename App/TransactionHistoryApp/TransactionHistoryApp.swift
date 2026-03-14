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

extension ProcessInfo {
    static let isTestEnvironmentKey = "IS_UI_TESTING"

    static var isTest: Bool {
        let env = ProcessInfo.processInfo.environment
        return env["XCTestConfigurationFilePath"] != nil
            || env[isTestEnvironmentKey] == "1"
    }
}

@main
struct TransactionHistoryApp: App {
    let dataStorage = DataStorage()

    var container: ModelContainer {
        if ProcessInfo.isTest {
            DataStorage.createMockEnvironment()
        } else {
            dataStorage.sharedModelContainer
        }
    }

    init() {
        TransactionHistoryProvider.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            TransactionCoordinatorView()
        }
        #if targetEnvironment(simulator)
        .modelContainer(DataStorage.createMockEnvironment())
        #else
        .modelContainer(container)
        #endif
    }
}
