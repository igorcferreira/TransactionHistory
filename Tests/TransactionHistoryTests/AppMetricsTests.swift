//
//  AppMetricsTests.swift
//  TransactionHistory
//
//  Created by Claude on 19/03/2026.
//

import Metrics
import Testing
@testable import TransactionHistory

@Suite("AppMetrics")
struct AppMetricsTests {

    init() {
        _ = TestBootstrap.appMetrics
    }

    @Test("bootstrap can be called multiple times without crashing")
    func bootstrapIsIdempotent() {
        // GIVEN the metrics system is already bootstrapped
        // WHEN bootstrap is called again
        AppMetrics.bootstrap()
        // THEN no crash occurs
    }

    @Test("makeCounter returns a valid counter")
    func makeCounterReturnsCounter() {
        // GIVEN a label
        let label = "test.counter"
        // WHEN creating a counter
        let counter = AppMetrics.makeCounter(label: label)
        // THEN incrementing does not crash
        counter.increment()
    }

    @Test("makeTimer returns a valid timer")
    func makeTimerReturnsTimer() {
        // GIVEN a label
        let label = "test.timer"
        // WHEN creating a timer
        let timer = AppMetrics.makeTimer(label: label)
        // THEN recording a value does not crash
        timer.recordNanoseconds(42)
    }

    @Test("makeGauge returns a valid gauge")
    func makeGaugeReturnsGauge() {
        // GIVEN a label
        let label = "test.gauge"
        // WHEN creating a gauge
        let gauge = AppMetrics.makeGauge(label: label)
        // THEN recording a value does not crash
        gauge.record(1.0)
    }

    @Test("makeCounter supports custom dimensions")
    func makeCounterWithDimensions() {
        // GIVEN a label and dimensions
        let label = "test.dimensioned"
        let dimensions: [(String, String)] = [("env", "test")]
        // WHEN creating a counter with dimensions
        let counter = AppMetrics.makeCounter(label: label, dimensions: dimensions)
        // THEN incrementing does not crash
        counter.increment()
    }
}
