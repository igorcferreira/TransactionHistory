//
//  CategoryPickerViewModel.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 09/05/2026.
//

import Foundation
import Logging
import SwiftData

@Observable
@MainActor
final class CategoryPickerViewModel {
    private let transactionID: UUID
    private let container: ModelContainer
    private let logger: Logger

    private(set) var transaction: CardTransaction?
    var errorMessage: String?

    var selectableCategories: [EntryCategory] { EntryCategory.allCases }

    var transactionName: String {
        guard let transaction else { return "" }
        if transaction.name.isEmpty {
            return transaction.merchant.isEmpty
                ? transaction.formattedAmount
                : transaction.merchant
        }
        return transaction.name
    }

    init(
        transactionID: UUID,
        container: ModelContainer,
        logger: Logger = AppLogger.makeLogger(label: "feature.categoryPicker")
    ) {
        self.transactionID = transactionID
        self.container = container
        self.logger = logger
    }

    func loadTransaction() {
        let context = ModelContext(container)
        let id = transactionID
        var descriptor = FetchDescriptor<CardTransaction>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            transaction = try context.fetch(descriptor).first
            if transaction == nil {
                logger.warning(
                    "Transaction not found",
                    metadata: ["transactionID": "\(transactionID.uuidString)"]
                )
            }
        } catch {
            logger.error(
                "Failed to fetch transaction",
                metadata: [
                    "transactionID": "\(transactionID.uuidString)",
                    "error": "\(error.localizedDescription)"
                ]
            )
        }
    }

    func setCategory(_ category: EntryCategory) {
        guard let transaction else { return }
        let context = ModelContext(container)
        let id = transaction.id
        var descriptor = FetchDescriptor<CardTransaction>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            guard let managed = try context.fetch(descriptor).first else { return }
            try context.transaction {
                managed.category = category
                try context.save()
            }
            self.transaction?.category = category
            logger.info(
                "Category updated",
                metadata: [
                    "transactionID": "\(id.uuidString)",
                    "category": "\(category.rawValue)"
                ]
            )
        } catch {
            errorMessage = String(localized: "Failed to update category. Please try again.")
            logger.error(
                "Failed to update category",
                metadata: [
                    "transactionID": "\(id.uuidString)",
                    "error": "\(error.localizedDescription)"
                ]
            )
        }
    }

    func displayName(for category: EntryCategory) -> String {
        .init(localized: .init(stringLiteral: category.rawValue.capitalized))
    }
}
