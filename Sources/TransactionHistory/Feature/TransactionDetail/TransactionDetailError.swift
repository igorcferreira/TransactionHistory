//
//  TransactionDetailError.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 27/04/2026.
//
import Foundation

enum TransactionDetailError: LocalizedError {
    case saveFailed
    case deleteFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Unable to save changes. Please try again."
        case .deleteFailed:
            return "Unable to delete the transaction. Please try again."
        }
    }
}
