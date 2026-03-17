//
//  EntryCategory.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import Foundation
import AppIntents

extension EntryCategory: AppEnum {
    public static let typeDisplayRepresentation: TypeDisplayRepresentation = "Category"
    public static var caseDisplayRepresentations: [EntryCategory: DisplayRepresentation] {
        [
            .food: "Food & Drink",
            .shopping: "Shopping",
            .travel: "Travel",
            .services: "Services",
            .entertrainment: "Entertainment",
            .health: "Health & Wellness",
            .transport: "Transport",
            .generic: "Generic"
        ]
    }
}
