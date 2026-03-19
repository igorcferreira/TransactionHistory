//
//  AppLogger.swift
//  TransactionHistory
//
//  Created by Codex on 18/03/2026.
//

import Foundation
import Logging
import SwiftUI

nonisolated
public enum AppLogger: Sendable {
    private static let bootstrapLock = NSLock()
    nonisolated(unsafe) private static var isBootstrapped = false

    public static let defaultLogLevel: Logger.Level = {
#if DEBUG
        .debug
#else
        .info
#endif
    }()

    static let defaultLogger = makeLogger(label: "app")

    static func makeLogger(
        label: String,
        logLevel: Logger.Level? = nil,
        metadata: Logger.Metadata = [:]
    ) -> Logger {
        bootstrap()

        var logger = Logger(label: "dev.igorcferreira.TransactionHistory.\(label)")
        logger.logLevel = logLevel ?? defaultLogLevel
        logger[metadataKey: "component"] = .string(label)

        for (key, value) in metadata {
            logger[metadataKey: key] = value
        }

        return logger
    }

    public static func bootstrap(logLevel: Logger.Level = defaultLogLevel) {
        bootstrapLock.lock()
        defer { bootstrapLock.unlock() }

        guard !isBootstrapped else { return }
        LoggingSystem.bootstrap { label in
            makeLogHandler(label: label, logLevel: logLevel)
        }
        isBootstrapped = true
    }

    static func makeLogHandler(
        label: String,
        logLevel: Logger.Level
    ) -> StreamLogHandler {
        var handler = StreamLogHandler.standardError(label: label)
        handler.logLevel = logLevel
        return handler
    }
}

private struct TransactionHistoryLoggerKey: EnvironmentKey {
    static let defaultValue: Logger = AppLogger.defaultLogger
}

public extension EnvironmentValues {
    var transactionHistoryLogger: Logger {
        get { self[TransactionHistoryLoggerKey.self] }
        set { self[TransactionHistoryLoggerKey.self] = newValue }
    }
}

public extension View {
    func transactionHistoryLogger(_ logger: Logger) -> some View {
        environment(\.transactionHistoryLogger, logger)
    }
}

nonisolated
public extension Logger {
    func scoped(
        _ label: String,
        metadata: Logger.Metadata = [:]
    ) -> Logger {
        var scopedLogger = self
        scopedLogger[metadataKey: "component"] = .string(label)

        for (key, value) in metadata {
            scopedLogger[metadataKey: key] = value
        }

        return scopedLogger
    }
}
