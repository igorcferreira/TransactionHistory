//
//  DataStorage.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import Foundation
import SwiftData

public struct DataStorage: Sendable {
    var modelContext: ModelContext {
        ModelContext(sharedModelContainer)
    }
    public let sharedModelContainer: ModelContainer

    public init() {
        self.sharedModelContainer = Self.createMockEnvironment(memoryOnly: false)
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

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}

public extension DataStorage {
    @MainActor
    static func createMockEnvironment() -> ModelContainer {
        let container = Self.createMockEnvironment(memoryOnly: true)
        let context = ModelContext(container)

        let merchants = [
            "Coffee Corner", "TechStore", "Grocery Mart",
            "Book Haven", "Gas Station", "Coffee Corner",
            "Pharmacy Plus", "TechStore", "Restaurant Lux"
        ]

        try? context.transaction {
            for index in (1..<10) {
                context.insert(CardTransaction(
                    name: "Transaction \(index)",
                    currency: "EUR",
                    amount: Double.random(in: 0.5..<100.0),
                    merchant: merchants[index - 1],
                    card: "Card 1"
                ))
            }
            try context.save()
        }

        return container
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
