//
//  AppMetrics.swift
//  TransactionHistory
//
//  Created by Claude on 19/03/2026.
//

import Foundation
import Metrics

nonisolated
public enum AppMetrics: Sendable {
    private static let bootstrapLock = NSLock()
    nonisolated(unsafe) private static var isBootstrapped = false

    /// Marks the metrics system as externally bootstrapped.
    /// Call this when an external framework (e.g. Scout) will handle
    /// `MetricsSystem.bootstrap` to prevent the lazy bootstrap from racing.
    public static func prepareForExternalBootstrap() {
        bootstrapLock.lock()
        defer { bootstrapLock.unlock() }
        isBootstrapped = true
    }

    /// Bootstraps the metrics system with the given factory.
    /// Defaults to `NOOPMetricsHandler.instance` so the package ships with
    /// zero overhead. The app entry point can call this with a real backend.
    public static func bootstrap(_ factory: any MetricsFactory = NOOPMetricsHandler.instance) {
        bootstrapLock.lock()
        defer { bootstrapLock.unlock() }

        guard !isBootstrapped else { return }
        MetricsSystem.bootstrap(factory)
        isBootstrapped = true
    }

    /// Creates a `Counter` with a namespaced label.
    static func makeCounter(
        label: String,
        dimensions: [(String, String)] = []
    ) -> Counter {
        bootstrap()
        return Counter(
            label: "dev.igorcferreira.TransactionHistory.\(label)",
            dimensions: dimensions
        )
    }

    /// Creates a `Timer` with a namespaced label.
    static func makeTimer(
        label: String,
        dimensions: [(String, String)] = []
    ) -> CoreMetrics.Timer {
        bootstrap()
        return CoreMetrics.Timer(
            label: "dev.igorcferreira.TransactionHistory.\(label)",
            dimensions: dimensions
        )
    }

    /// Creates a `Gauge` with a namespaced label.
    static func makeGauge(
        label: String,
        dimensions: [(String, String)] = []
    ) -> Gauge {
        bootstrap()
        return Gauge(
            label: "dev.igorcferreira.TransactionHistory.\(label)",
            dimensions: dimensions
        )
    }
}
