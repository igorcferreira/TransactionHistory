//
//  NotificationRouterTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 09/05/2026.
//

import Foundation
import Testing
@testable import TransactionHistory

@Suite("NotificationRouter")
struct NotificationRouterTests {

    @Test("pendingCategoryTransactionID starts as nil")
    @MainActor
    func pendingStartsNil() {
        // GIVEN a freshly created router
        let router = NotificationRouter()
        // THEN there is no pending transaction
        #expect(router.pendingCategoryTransactionID == nil)
    }

    @Test("pendingCategoryTransactionID can be set and cleared")
    @MainActor
    func pendingCanBeSetAndCleared() {
        // GIVEN a router
        let router = NotificationRouter()
        let id = UUID()
        // WHEN setting a pending transaction
        router.pendingCategoryTransactionID = id
        // THEN the value is available
        #expect(router.pendingCategoryTransactionID == id)
        // WHEN clearing
        router.pendingCategoryTransactionID = nil
        // THEN the value is nil
        #expect(router.pendingCategoryTransactionID == nil)
    }
}
