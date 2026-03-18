//
//  AppLoggerTests.swift
//  TransactionHistory
//
//  Created by Codex on 18/03/2026.
//

import Logging
import Testing
@testable import TransactionHistory

@Suite("AppLogger")
struct AppLoggerTests {
    @Test("defaultLogLevel matches the build configuration")
    func defaultLogLevelMatchesBuildConfiguration() {
#if DEBUG
        #expect(AppLogger.defaultLogLevel == .debug)
#else
        #expect(AppLogger.defaultLogLevel == .info)
#endif
    }

    @Test("makeLogHandler applies the requested log level")
    func makeLogHandlerAppliesRequestedLogLevel() {
        // GIVEN a requested log level
        let requestedLogLevel = Logger.Level.error
        // WHEN creating a handler
        let handler = AppLogger.makeLogHandler(
            label: "test",
            logLevel: requestedLogLevel
        )
        // THEN the handler uses that level
        #expect(handler.logLevel == requestedLogLevel)
    }
}
