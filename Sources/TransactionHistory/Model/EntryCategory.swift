//
//  EntryCategory.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 17/03/2026.
//
import Foundation

nonisolated
public enum EntryCategory: String, Codable, CaseIterable, Sendable {
    case generic = "Generic"
    case food = "Food & Drink"
    case shopping = "Shopping"
    case travel = "Travel"
    case services = "Services"
    case entertrainment = "Entertrainment"
    case health = "Health"
    case transport = "Transport"
}
