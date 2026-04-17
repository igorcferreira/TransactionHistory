//
//  MockDataSeeder.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 17/04/2026.
//

import Foundation
import SwiftData

/// Inserts a deterministic set of sample transactions into an in-memory container.
/// Used for simulator, Xcode Previews, and UI testing environments.
struct MockDataSeeder {

    private static let logger = AppLogger.makeLogger(label: "storage.seeder")

    // MARK: - Seed entry point

    static func seed(in container: ModelContainer) {
        let context = ModelContext(container)
        do {
            try context.transaction {
                for entry in entries {
                    context.insert(entry.asTransaction())
                }
                try context.save()
            }
            Self.logger.debug("Seeded mock transaction data", metadata: ["count": "\(entries.count)"])
        } catch {
            Self.logger.error("Failed to seed mock transaction data", metadata: ["error": "\(error)"])
        }
    }

    // MARK: - Template

    private struct Entry {
        let name: String
        let amount: Double
        let merchant: String
        let card: String
        let category: EntryCategory
        let currency: String
        // Negative offset from today: monthsAgo months back, on a fixed day-of-month.
        let monthsAgo: Int
        let day: Int

        func asTransaction() -> CardTransaction {
            CardTransaction(
                name: name,
                currency: currency,
                amount: amount,
                merchant: merchant,
                card: card,
                category: category,
                createdAt: Self.date(monthsAgo: monthsAgo, day: day)
            )
        }

        private static func date(monthsAgo: Int, day: Int) -> Date {
            let calendar = Calendar.current
            let now = Date()
            guard let base = calendar.date(byAdding: .month, value: -monthsAgo, to: now) else { return now }
            var components = calendar.dateComponents([.year, .month], from: base)
            components.day = min(day, 28) // clamp so February is always valid
            return calendar.date(from: components) ?? now
        }
    }

    // MARK: - Sample data (6 months, deterministic)

    // swiftlint:disable line_length
    private static let entries: [Entry] = [

        // Current month
        Entry(name: "Morning Coffee", amount: 4.50, merchant: "Coffee Corner", card: "Card 1", category: .food, currency: "EUR", monthsAgo: 0, day: 5),
        Entry(name: "Metro Pass", amount: 35.00, merchant: "City Transit", card: "Card 1", category: .transport, currency: "EUR", monthsAgo: 0, day: 7),
        Entry(name: "Lunch", amount: 18.90, merchant: "Restaurant Lux", card: "Card 1", category: .food, currency: "EUR", monthsAgo: 0, day: 12),
        Entry(name: "Vitamins", amount: 22.00, merchant: "Pharmacy Plus", card: "Card 2", category: .health, currency: "EUR", monthsAgo: 0, day: 15),
        Entry(name: "New Headphones", amount: 89.99, merchant: "TechStore", card: "Card 2", category: .shopping, currency: "EUR", monthsAgo: 0, day: 20),

        // 1 month ago
        Entry(name: "Groceries", amount: 67.40, merchant: "Grocery Mart", card: "Card 1", category: .food, currency: "EUR", monthsAgo: 1, day: 3),
        Entry(name: "Train Tickets", amount: 54.00, merchant: "Rail Europe", card: "Card 1", category: .travel, currency: "EUR", monthsAgo: 1, day: 9),
        Entry(name: "Bookshop", amount: 28.50, merchant: "Book Haven", card: "Card 2", category: .shopping, currency: "EUR", monthsAgo: 1, day: 14),
        Entry(name: "Dinner Out", amount: 42.00, merchant: "Bistro Chez", card: "Card 1", category: .food, currency: "EUR", monthsAgo: 1, day: 18),
        Entry(name: "Cloud Storage", amount: 9.99, merchant: "CloudSync", card: "Card 2", category: .services, currency: "EUR", monthsAgo: 1, day: 22),
        Entry(name: "Sneakers", amount: 119.00, merchant: "SportShop", card: "Card 2", category: .shopping, currency: "EUR", monthsAgo: 1, day: 26),

        // 2 months ago
        Entry(name: "Supermarket", amount: 53.20, merchant: "Grocery Mart", card: "Card 1", category: .food, currency: "EUR", monthsAgo: 2, day: 2),
        Entry(name: "Cinema", amount: 14.50, merchant: "CinePlex", card: "Card 1", category: .entertrainment, currency: "EUR", monthsAgo: 2, day: 6),
        Entry(name: "Internet Bill", amount: 39.99, merchant: "TeleNet", card: "Card 2", category: .services, currency: "EUR", monthsAgo: 2, day: 10),
        Entry(name: "Café", amount: 7.80, merchant: "Coffee Corner", card: "Card 1", category: .food, currency: "EUR", monthsAgo: 2, day: 16),
        Entry(name: "Concert Ticket", amount: 65.00, merchant: "TicketMaster", card: "Card 2", category: .entertrainment, currency: "EUR", monthsAgo: 2, day: 21),
        Entry(name: "Shirt", amount: 34.95, merchant: "FashionHub", card: "Card 2", category: .shopping, currency: "EUR", monthsAgo: 2, day: 25),

        // 3 months ago
        Entry(name: "Sushi Dinner", amount: 55.00, merchant: "Sushi Zen", card: "Card 1", category: .food, currency: "EUR", monthsAgo: 3, day: 4),
        Entry(name: "Flight", amount: 210.00, merchant: "AirEurope", card: "Card 2", category: .travel, currency: "EUR", monthsAgo: 3, day: 8),
        Entry(name: "Hotel (1 night)", amount: 120.00, merchant: "Central Hotel", card: "Card 2", category: .travel, currency: "EUR", monthsAgo: 3, day: 9),
        Entry(name: "Pharmacy", amount: 18.60, merchant: "Pharmacy Plus", card: "Card 1", category: .health, currency: "EUR", monthsAgo: 3, day: 17),
        Entry(name: "Bakery", amount: 6.20, merchant: "Golden Bakery", card: "Card 1", category: .food, currency: "EUR", monthsAgo: 3, day: 23),

        // 4 months ago
        Entry(name: "Takeaway", amount: 23.50, merchant: "FoodBox", card: "Card 1", category: .food, currency: "EUR", monthsAgo: 4, day: 1),
        Entry(name: "Fuel", amount: 60.00, merchant: "Gas Station", card: "Card 1", category: .transport, currency: "EUR", monthsAgo: 4, day: 7),
        Entry(name: "Dentist", amount: 80.00, merchant: "Dental Care", card: "Card 2", category: .health, currency: "EUR", monthsAgo: 4, day: 13),
        Entry(name: "Groceries", amount: 48.30, merchant: "Grocery Mart", card: "Card 1", category: .food, currency: "EUR", monthsAgo: 4, day: 19),
        Entry(name: "Bus Card", amount: 25.00, merchant: "City Transit", card: "Card 1", category: .transport, currency: "EUR", monthsAgo: 4, day: 24),
        Entry(name: "Misc Purchase", amount: 11.00, merchant: "General Store", card: "Card 1", category: .generic, currency: "EUR", monthsAgo: 4, day: 27),

        // 5 months ago
        Entry(name: "Brunch", amount: 31.00, merchant: "Sunny Brunch", card: "Card 1", category: .food, currency: "EUR", monthsAgo: 5, day: 5),
        Entry(name: "Jacket", amount: 145.00, merchant: "FashionHub", card: "Card 2", category: .shopping, currency: "EUR", monthsAgo: 5, day: 10),
        Entry(name: "Streaming", amount: 13.99, merchant: "StreamNow", card: "Card 2", category: .services, currency: "EUR", monthsAgo: 5, day: 15),
        Entry(name: "Museum Entry", amount: 16.00, merchant: "City Museum", card: "Card 1", category: .entertrainment, currency: "EUR", monthsAgo: 5, day: 20),
        Entry(name: "Sandwiches", amount: 9.40, merchant: "Deli Express", card: "Card 1", category: .food, currency: "EUR", monthsAgo: 5, day: 25),
        Entry(name: "Shoes", amount: 99.00, merchant: "SportShop", card: "Card 2", category: .shopping, currency: "EUR", monthsAgo: 5, day: 28)
    ]
    // swiftlint:enable line_length
}
