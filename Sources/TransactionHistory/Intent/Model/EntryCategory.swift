//
//  EntryCategory.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import Foundation
import AppIntents

enum EntryCategory: String, Sendable {
    case food
    case shopping
    case travel
    case services
    case entertrainment
    case health
    case transport
}

extension EntryCategory: AppEnum {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Category"
    static var caseDisplayRepresentations: [EntryCategory: DisplayRepresentation] {
        [
            .food: "Food & Drink",
            .shopping: "Shopping",
            .travel: "Travel",
            .services: "Services",
            .entertrainment: "Entertainment",
            .health: "Health & Wellness",
            .transport: "Transport"
        ]
    }
}
