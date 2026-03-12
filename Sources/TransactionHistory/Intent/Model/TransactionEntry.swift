//
//  TransactionEntry.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import Foundation
import AppIntents

struct TransactionEntry: Sendable, Identifiable {
    var id: UUID
    var name: String
    var ammount: String

    init(id: UUID, name: String, ammount: String) {
        self.id = id
        self.name = name
        self.ammount = ammount
    }

    init(_ card: CardTransaction) {
        self.id = card.id
        self.name = card.name
        self.ammount = card.ammount
    }
}

extension TransactionEntry: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Transaction"
    static let defaultQuery: TransationEntryQuery = .init()

    var displayRepresentation: DisplayRepresentation {
        .init(
            title: .init(stringLiteral: name),
            subtitle: .init(stringLiteral: ammount)
        )
    }
}

struct TransationEntryQuery: EntityQuery, Sendable {
    let dataStorage = DataStorage()

    func entities(
        for identifiers: [TransactionEntry.ID]
    ) async throws -> [TransactionEntry] {
        let entries = try dataStorage.with(ids: identifiers)
        return entries.map({ .init($0) })
    }

    func suggestedEntities() async throws -> [TransactionEntry] {
        let entries = try dataStorage.top()
        return entries.map({ .init($0) })
    }
}
