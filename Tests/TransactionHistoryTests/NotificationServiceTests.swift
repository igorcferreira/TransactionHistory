//
//  NotificationServiceTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 09/05/2026.
//

import Foundation
import Testing
@testable import TransactionHistory

@Suite("NotificationService")
struct NotificationServiceTests {

    @Test("static identifiers are non-empty")
    func staticIdentifiers() {
        // GIVEN the static constants
        // THEN they are non-empty
        #expect(!NotificationService.categoryIdentifier.isEmpty)
        #expect(!NotificationService.setCategoryActionIdentifier.isEmpty)
        #expect(!NotificationService.transactionIDKey.isEmpty)
    }

    @Test("categoryIdentifier and actionIdentifier are distinct")
    func identifiersAreDistinct() {
        // GIVEN the identifiers
        // THEN they don't collide
        #expect(NotificationService.categoryIdentifier != NotificationService.setCategoryActionIdentifier)
    }
}
