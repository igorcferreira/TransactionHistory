//
//  DataStorageError.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 27/04/2026.
//
import Foundation

enum DataStorageError: LocalizedError {
    case fetchFailed

    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            return "Unable to load transactions. Please try again."
        }
    }
}
