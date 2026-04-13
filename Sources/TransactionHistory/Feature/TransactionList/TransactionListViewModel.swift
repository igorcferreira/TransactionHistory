//
//  TransactionListViewModel.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import Foundation
import SwiftData
import Logging

/// Manages batched loading, sorting, and merchant search for the transaction list.
@Observable
final class TransactionListViewModel {
    /// Free-text filter applied against merchant name.
    var searchText: String = ""

    /// Sort direction for `createdAt`.
    var sortOrder: SortOrder = .reverse

    /// IDs of transactions selected for batch operations.
    var selection: Set<UUID> = []

    /// Error message surfaced to the user via toast.
    var errorMessage: String?

    /// Whether at least one transaction is selected.
    var hasSelection: Bool { !selection.isEmpty }

    /// Deletes all currently selected transactions from the store.
    func deleteSelected(
        on modelContext: ModelContext,
        logger: Logger
    ) -> Bool {
        do {
            errorMessage = nil
            let count = selection.count
            let selectedIDs = selection
            try modelContext.transaction {
                let descriptor = FetchDescriptor<CardTransaction>(
                    predicate: #Predicate { selectedIDs.contains($0.id) }
                )
                let toDelete = try modelContext.fetch(descriptor)
                for item in toDelete {
                    modelContext.delete(item)
                }
                try modelContext.save()
            }
            selection.removeAll()
            logger.info(
                "Deleted selected transactions",
                metadata: ["count": "\(count)"]
            )
            return true
        } catch {
            logger.error(
                "Failed to delete selected transactions",
                metadata: ["error": "\(error)"]
            )
            errorMessage = error.localizedDescription
            return false
        }
    }
}
