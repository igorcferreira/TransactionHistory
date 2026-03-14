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

#if os(macOS)
import AppKit
#endif

extension ProcessInfo {
    static var isTest: Bool {
        ProcessInfo
            .processInfo
            .environment["XCTestConfigurationFilePath"] != nil
    }
}

@main
struct TransactionHistoryApp: App {
    let dataStorage = DataStorage()

    #if os(macOS)
    // Observes system appearance changes to switch the Dock icon
    @Environment(\.colorScheme) private var colorScheme
    #endif

    var container: ModelContainer {
        if ProcessInfo.isTest {
            DataStorage.createMockEnvironment()
        } else {
            dataStorage.sharedModelContainer
        }
    }

    init() {
        TransactionHistoryProvider.updateAppShortcutParameters()
        #if os(macOS)
        updateMacOSIcon()
        observeAppearanceChanges()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            TransactionListView()
        }
        #if targetEnvironment(simulator)
        .modelContainer(DataStorage.createMockEnvironment())
        #else
        .modelContainer(dataStorage.sharedModelContainer)
        #endif
    }

    #if os(macOS)
    /// Updates the macOS Dock icon based on the current system appearance.
    private func updateMacOSIcon() {
        let isDark = NSApp?.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        if isDark {
            NSApp?.applicationIconImage = NSImage(named: "AppIcon-Dark")
        } else {
            // nil resets to the default app icon
            NSApp?.applicationIconImage = nil
        }
    }

    /// Observes system appearance changes to keep the Dock icon in sync.
    private func observeAppearanceChanges() {
        DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { _ in
            updateMacOSIcon()
        }
    }
    #endif
}
