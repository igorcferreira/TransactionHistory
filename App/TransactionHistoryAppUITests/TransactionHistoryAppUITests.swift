//
//  TransactionHistoryAppUITests.swift
//  TransactionHistoryAppUITests
//
//  Created by Igor Ferreira on 12/03/2026.
//

import XCTest
@testable import TransactionHistoryApp
@testable import TransactionHistory

final class TransactionHistoryAppUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation
        // required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launchEnvironment[ProcessInfo.isTestEnvironmentKey] = "1"
            app.launch()
        }
    }
}
