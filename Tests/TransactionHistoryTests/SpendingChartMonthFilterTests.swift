//
//  SpendingChartMonthFilterTests.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 17/04/2026.
//

import Foundation
import Testing
@testable import TransactionHistory

@Suite("SpendingChartViewModel — Month Filtering")
struct SpendingChartMonthFilterTests {

    // MARK: - YearMonth.dateInterval boundary tests
    //
    // createQuery(for:) builds its predicate as:
    //   createdAt >= interval.start && createdAt < interval.end
    //
    // These tests verify that start and end are set to the correct calendar
    // boundaries, which in turn proves the query will fetch exactly the right rows.

    private static func date(year: Int, month: Int, day: Int = 1) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)!
    }

    @Test("dateInterval start is midnight on the 1st of the month")
    func dateIntervalStartIsFirstOfMonth() {
        // GIVEN March 2026
        let yearMonth = YearMonth(year: 2026, month: 3)

        // THEN interval.start is March 1 00:00 local
        #expect(yearMonth.dateInterval.start == Self.date(year: 2026, month: 3, day: 1))
    }

    @Test("dateInterval end is midnight on the 1st of the next month")
    func dateIntervalEndIsFirstOfNextMonth() {
        // GIVEN March 2026
        let yearMonth = YearMonth(year: 2026, month: 3)

        // THEN interval.end is April 1 00:00 local (excluded by the < predicate)
        #expect(yearMonth.dateInterval.end == Self.date(year: 2026, month: 4, day: 1))
    }

    @Test("dateInterval for December ends at January 1st of the following year")
    func dateIntervalDecemberEndsInJanuary() {
        // GIVEN December 2025
        let yearMonth = YearMonth(year: 2025, month: 12)

        // THEN interval.end is January 1 2026 (year boundary wraps correctly)
        #expect(yearMonth.dateInterval.end == Self.date(year: 2026, month: 1, day: 1))
    }

    @Test("dateInterval start and end span exactly one month")
    func dateIntervalSpansOneMonth() {
        // GIVEN February 2026 (non-leap year, 28 days)
        let yearMonth = YearMonth(year: 2026, month: 2)
        let interval = yearMonth.dateInterval

        // THEN the gap between start and end is 28 days
        let days = Calendar.current.dateComponents([.day], from: interval.start, to: interval.end).day
        #expect(days == 28)
    }

    // MARK: - Navigation state tests

    @Test("canGoToNextMonth is false when on current month")
    @MainActor
    func canGoToNextMonthFalseOnCurrentMonth() {
        // GIVEN a view model on the current month
        let viewModel = SpendingChartViewModel()
        viewModel.selectedYearMonth = .current

        // THEN forward navigation is disabled
        #expect(!viewModel.canGoToNextMonth)
    }

    @Test("canGoToNextMonth is true when on a past month")
    @MainActor
    func canGoToNextMonthTrueOnPastMonth() {
        // GIVEN a view model on a past month
        let viewModel = SpendingChartViewModel()
        viewModel.selectedYearMonth = YearMonth(year: 2025, month: 1)

        // THEN forward navigation is enabled
        #expect(viewModel.canGoToNextMonth)
    }

    @Test("goToPreviousMonth from January wraps to December of prior year")
    @MainActor
    func previousMonthWrapsFromJanuaryToDecember() {
        // GIVEN the selected month is January 2026
        let viewModel = SpendingChartViewModel()
        viewModel.selectedYearMonth = YearMonth(year: 2026, month: 1)

        // WHEN navigating to the previous month
        viewModel.goToPreviousMonth()

        // THEN the selected month is December 2025
        #expect(viewModel.selectedYearMonth == YearMonth(year: 2025, month: 12))
    }

    @Test("goToNextMonth from December wraps to January of next year")
    @MainActor
    func nextMonthWrapsFromDecemberToJanuary() {
        // GIVEN the selected month is December 2024
        let viewModel = SpendingChartViewModel()
        viewModel.selectedYearMonth = YearMonth(year: 2024, month: 12)

        // WHEN navigating to the next month
        viewModel.goToNextMonth()

        // THEN the selected month is January 2025
        #expect(viewModel.selectedYearMonth == YearMonth(year: 2025, month: 1))
    }
}
