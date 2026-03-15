//
//  DataStorage.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import Foundation
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
    }

    /// Internal init for testing with a custom container.
    init(container: ModelContainer) {
        self.sharedModelContainer = container
    }

    func top() throws -> [CardTransaction] {
        var descriptor = FetchDescriptor<CardTransaction>(
            sortBy: [
                SortDescriptor(\.createdAt, order: .reverse)
            ]
        )
        descriptor.fetchLimit = 10
        return try modelContext.fetch(descriptor)
    }

    func with(ids: [UUID]) throws -> [CardTransaction] {
        try modelContext.fetch(FetchDescriptor<CardTransaction>(
            predicate: #Predicate { item in ids.contains(item.id) }
        ))
    }
}

private extension DataStorage {
    static func createMockEnvironment(
        memoryOnly: Bool,
        group: String = "group.dev.igorcferreira.TransactionHistoryApp"
    ) -> ModelContainer {
        let schema = Schema([
            CardTransaction.self
        ])

        // A memory-only configuration cannot be saved in an app group.
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: memoryOnly,
            groupContainer: memoryOnly ? .automatic : .identifier(group),
            cloudKitDatabase: memoryOnly ? .none : .automatic
        )

        let container: ModelContainer
        do {
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
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

        try? context.transaction {
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
                    createdAt: date
                ))
            }
            try context.save()
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
