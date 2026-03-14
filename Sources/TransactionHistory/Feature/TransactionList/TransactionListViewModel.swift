//
//  TransactionListViewModel.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import Foundation
import SwiftData

/// Manages batched loading, sorting, and merchant search for the transaction list.
@Observable
final class TransactionListViewModel {
    /// Free-text filter applied against merchant name.
    var searchText: String = ""

    /// Sort direction for `createdAt`.
    var sortOrder: SortOrder = .reverse
}
