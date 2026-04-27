//
//  CreateTransactionIntent.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import AppIntents
import Foundation
import Logging
import Metrics
import SwiftData

struct CreateTransactionIntent: AppIntent, Sendable {
    struct CreateTransactionRequest: Sendable {
        let name: String
        let merchant: String
        let amount: String
        let card: String
        let category: EntryCategory
        let date: Date?
    }

    enum CreateTransactionError: LocalizedError {
        case invalidAmount
        case databaseError

        var errorDescription: String? {
            switch self {
            case .invalidAmount:
                return "Invalid amount. The amount must be formatted with a valid currency symbol and value."
            case .databaseError:
                return "Unable to save the transaction. Please try again."
            }
        }
    }

    static let title: LocalizedStringResource = "Create Transaction"
    static let supportedModes: IntentModes = .background

    private static let creationCounter = AppMetrics.makeCounter(label: "transaction.created")
    private static let creationFailureCounter = AppMetrics.makeCounter(label: "transaction.creation.failed")

    private let container: ModelContainer
    private let logger: Logger

    init(
        container: ModelContainer,
        logger: Logger = AppLogger.makeLogger(label: "intent.createTransaction")
    ) {
        self.container = container
        self.logger = logger
    }

    init() {
        self.container = DataStorage().sharedModelContainer
        self.logger = AppLogger.makeLogger(label: "intent.createTransaction")
    }

    @Parameter(
        title: "Name",
        requestValueDialog: "What is the name of this transaction?"
    )
    var name: String?
    @Parameter(
        title: "Merchant",
        requestValueDialog: "Where was this transaction made?"
    )
    var merchant: String?
    @Parameter(
        title: "Amount",
        requestValueDialog: "How much was this transaction?"
    )
    var amount: String
    @Parameter(
        title: "Card",
        requestValueDialog: "Which card was used for this transaction?"
    )
    var card: String?
    @Parameter(
        title: "Purchase date",
        default: nil,
        requestValueDialog: "When was this transaction made?"
    )
    var date: Date?
    @Parameter(
        title: "Category",
        default: nil,
        requestValueDialog: "What is the category of the purchase?"
    )
    var category: EntryCategory?

    func perform() async throws -> some ReturnsValue<TransactionEntry> {
        logger.info(
            "Performing create transaction intent",
            metadata: [
                "hasCustomDate": "\(date != nil)",
                "category": "\((category ?? .generic).rawValue)"
            ]
        )
        let card = try createTransaction(.init(
            name: name ?? "",
            merchant: merchant ?? "",
            amount: amount,
            card: card ?? "",
            category: category ?? .generic,
            date: date
        ))
        logger.info(
            "Create transaction intent completed",
            metadata: ["transactionID": "\(card.id.uuidString)"]
        )
        return .result(value: .init(card))
    }

    /// Persists a transaction in the given model context.
    func createTransaction(
        _ request: CreateTransactionRequest
    ) throws(CreateTransactionError) -> CardTransaction {
        let mapper = CurrencyMapper()
        guard let mapped = mapper.parse(request.amount) else {
            Self.creationFailureCounter.increment()
            logger.warning(
                "Rejected transaction creation because amount parsing failed",
                metadata: [
                    "merchant": "\(request.merchant)",
                    "amountInputLength": "\(request.amount.count)",
                    "category": "\(request.category.rawValue)"
                ]
            )
            throw CreateTransactionError.invalidAmount
        }
        let transaction = CardTransaction(
            name: request.name,
            currency: mapped.code,
            amount: mapped.value,
            merchant: request.merchant,
            card: request.card,
            category: request.category,
            createdAt: request.date ?? Date()
        )
        let ctx = ModelContext(container)
        do {
            try ctx.transaction {
                ctx.insert(transaction)
                try ctx.save()
            }
            Self.creationCounter.increment()
            logger.info(
                "Persisted transaction",
                metadata: [
                    "transactionID": "\(transaction.id.uuidString)",
                    "merchant": "\(request.merchant)",
                    "currency": "\(mapped.code)",
                    "amount": "\(mapped.value)",
                    "category": "\(request.category.rawValue)",
                    "createdAt": "\(transaction.createdAt.ISO8601Format())"
                ]
            )
            return transaction
        } catch {
            throw CreateTransactionError.databaseError
        }
    }

    /// Executes the intent via `callAsFunction(donate:)`.
    /// Pass `donate: false` in test environments where the AppIntents
    /// runtime is not available (package tests).
    static func execute(
        name: String,
        merchant: String,
        amount: String,
        card: String,
        category: EntryCategory? = nil,
        date: Date? = nil,
        donate: Bool = true,
        container: ModelContainer = DataStorage().sharedModelContainer,
        logger: Logger = AppLogger.makeLogger(label: "intent.createTransaction")
    ) async throws(CreateTransactionError) {
        let logger = logger.scoped(
            "intent.createTransaction",
            metadata: [
                "entryPoint": "ui",
                "hasCustomDate": "\(date != nil)"
            ]
        )
        logger.debug(
            "Executing create transaction flow",
            metadata: [
                "merchant": "\(merchant)",
                "category": "\((category ?? .generic).rawValue)"
            ]
        )
        let intent = CreateTransactionIntent(container: container, logger: logger)
        intent.name = name
        intent.merchant = merchant
        intent.amount = amount
        intent.card = card
        intent.date = date
        intent.category = category
        do {
            _ = try await intent.callAsFunction(donate: donate)
        } catch let error as CreateTransactionError {
            throw error
        } catch {
            throw CreateTransactionError.databaseError
        }
    }
}
