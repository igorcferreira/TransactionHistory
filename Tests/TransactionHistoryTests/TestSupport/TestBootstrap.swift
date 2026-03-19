//
//  TestBootstrap.swift
//  TransactionHistory
//
//  Created by Codex on 18/03/2026.
//

@testable import TransactionHistory

enum TestBootstrap {
    static let appLogger: Void = {
        AppLogger.bootstrap()
    }()

    static let appMetrics: Void = {
        AppMetrics.bootstrap()
    }()
}
