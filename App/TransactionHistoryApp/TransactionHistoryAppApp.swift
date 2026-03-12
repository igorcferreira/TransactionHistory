//
//  TransactionHistoryAppApp.swift
//  TransactionHistoryApp
//
//  Created by Igor Ferreira on 12/03/2026.
//

import SwiftUI
import SwiftData
import TransactionHistory

@main
struct TransactionHistoryAppApp: App {
    let dataStorage = DataStorage()

    var body: some Scene {
        WindowGroup {
            TransactionListView()
        }
        #if DEBUG
        .modelContainer(DataStorage.createMockEnvironment())
        #else
        .modelContainer(dataStorage.sharedModelContainer)
        #endif
    }
}
