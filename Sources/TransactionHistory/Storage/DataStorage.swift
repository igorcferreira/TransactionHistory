//
//  DataStorage.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import Foundation
import Logging
import Metrics
import SwiftData

extension ProcessInfo {
    static let isTestEnvironmentKey = "IS_UI_TESTING"

    static var isTest: Bool {
        let env = ProcessInfo.processInfo.environment
        return env["XCTestConfigurationFilePath"] != nil
            || env[isTestEnvironmentKey] == "1"
    }
}

public struct DataStorage: Sendable {
    private static let logger = AppLogger.makeLogger(label: "storage.dataStorage")
    private static let fetchTimer = AppMetrics.makeTimer(label: "storage.fetch")

    var modelContext: ModelContext {
        ModelContext(sharedModelContainer)
    }
    public let sharedModelContainer: ModelContainer

    // Single shared container for the app lifetime.
    // On simulator or during tests an in-memory store is used;
    // on device the persistent app-group store with CloudKit sync.
    private static let shared: ModelContainer = {
        #if targetEnvironment(simulator)
        return createMockEnvironment(memoryOnly: true)
        #else
        if ProcessInfo.isTest {
            return createMockEnvironment(memoryOnly: true)
        } else {
            return createMockEnvironment(memoryOnly: false)
        }
        #endif
    }()

    public init() {
        self.sharedModelContainer = Self.shared
        Self.logger.debug("Initialized shared data storage")
    }

    /// Internal init for testing with a custom container.
    init(container: ModelContainer) {
        self.sharedModelContainer = container
    }

    func top() throws -> [CardTransaction] {
        let start = ContinuousClock.now
        var descriptor = FetchDescriptor<CardTransaction>(
            sortBy: [
                SortDescriptor(\.createdAt, order: .reverse)
            ]
        )
        descriptor.fetchLimit = 10
        let transactions = try modelContext.fetch(descriptor)
        Self.fetchTimer.record(duration: ContinuousClock.now - start)
        Self.logger.debug(
            "Fetched top transactions",
            metadata: [
                "resultCount": "\(transactions.count)",
                "fetchLimit": "10"
            ]
        )
        return transactions
    }

    func with(ids: [UUID]) throws -> [CardTransaction] {
        let start = ContinuousClock.now
        let transactions = try modelContext.fetch(FetchDescriptor<CardTransaction>(
            predicate: #Predicate { item in ids.contains(item.id) }
        ))
        Self.fetchTimer.record(duration: ContinuousClock.now - start)
        Self.logger.debug(
            "Fetched transactions by identifiers",
            metadata: [
                "requestedCount": "\(ids.count)",
                "resultCount": "\(transactions.count)"
            ]
        )
        return transactions
    }
}

private extension DataStorage {
    static func createMockEnvironment(
        memoryOnly: Bool,
        group: String = "group.dev.igorcferreira.TransactionHistoryApp",
        iCloudIdentifier: String = "iCloud.dev.igorcferreira.TransactionHistoryApp"
    ) -> ModelContainer {
        Self.logger.info(
            "Creating model container",
            metadata: [
                "memoryOnly": "\(memoryOnly)",
                "groupContainer": "\(memoryOnly ? "automatic" : group)",
                "iCloud": "\(memoryOnly ? "none" : iCloudIdentifier)"
            ]
        )
        let schema = Schema([
            CardTransaction.self
        ])

        // A memory-only configuration cannot be saved in an app group.
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: memoryOnly,
            groupContainer: memoryOnly ? .automatic : .identifier(group),
            cloudKitDatabase: memoryOnly ? .none : .private(iCloudIdentifier)
        )

        let container: ModelContainer
        do {
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            Self.logger.critical(
                "Failed to create model container",
                metadata: [
                    "memoryOnly": "\(memoryOnly)",
                    "error": "\(error)"
                ]
            )
            fatalError("Could not create ModelContainer: \(error)")
        }

        // Seed sample data for in-memory environments (simulator / tests).
        if memoryOnly {
            Self.seedMockData(in: container)
        }

        return container
    }

    /// Inserts sample transactions spread over the last 5 days.
    static func seedMockData(in container: ModelContainer) {
        let context = ModelContext(container)

        let merchants = [
            "Coffee Corner", "TechStore", "Grocery Mart",
            "Book Haven", "Gas Station", "Coffee Corner",
            "Pharmacy Plus", "TechStore", "Restaurant Lux"
        ]

        let now = Date()
        let calendar = Calendar.current

        do {
            try context.transaction {
                for index in (1..<10) {
                    // Spread transactions across the last 5 days.
                    let daysAgo = (index - 1) * 5 / 9
                    let date = calendar.date(
                        byAdding: .day, value: -daysAgo, to: now
                    ) ?? now

                    context.insert(CardTransaction(
                        name: "Transaction \(index)",
                        currency: "EUR",
                        amount: Double.random(in: 0.5..<100.0),
                        merchant: merchants[index - 1],
                        card: "Card 1",
                        category: EntryCategory.allCases.randomElement() ?? .generic,
                        createdAt: date,
                    ))
                }
                try context.save()
            }
            Self.logger.debug("Seeded mock transaction data", metadata: ["count": "9"])
        } catch {
            Self.logger.error(
                "Failed to seed mock transaction data",
                metadata: ["error": "\(error)"]
            )
        }
    }
}

public extension DataStorage {
    @MainActor
    static func createMockEnvironment() -> ModelContainer {
        createMockEnvironment(memoryOnly: true)
    }
}

import SwiftUI
internal extension View {
    @MainActor
    @ViewBuilder
    func includingMocks() -> some View {
        modelContainer(DataStorage.createMockEnvironment())
    }
}
