//
//  DataStorage.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import Foundation
import SwiftData

public struct DataStorage: Sendable {
    private var modelContext: ModelContext {
        ModelContext(sharedModelContainer)
    }
    public let sharedModelContainer: ModelContainer = {
        Self.createMockEnvironment(memoryOnly: false)
    }()

    public init() {}

    func top() throws -> [CardTransaction] {
        let batch = try modelContext.fetch(
            FetchDescriptor<CardTransaction>(
                sortBy: [
                    SortDescriptor(\.createdAt, order: .reverse)
                ]
            ),
            batchSize: 10
        )
        return Array(batch)
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
            groupContainer: memoryOnly ? .automatic : .identifier(group)
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

        try? context.transaction {
            for index in (1..<10) {
                context.insert(CardTransaction(
                    name: "Transaction \(index)",
                    currency: "EUR",
                    amount: Double.random(in: 0.5..<100.0),
                    merchant: "Merchant",
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
