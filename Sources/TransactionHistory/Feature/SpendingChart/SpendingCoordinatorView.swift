//
//  SpendingCoordinatorView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 15/04/2026.
//

import SwiftUI

/// Coordinator that owns the NavigationStack for the spending chart feature.
public struct SpendingCoordinatorView: View {
    @Environment(\.transactionHistoryLogger) private var logger
    @State private var viewModel = SpendingCoordinatorViewModel()

    public init() {}

    public var body: some View {
        let coordinatorLogger = logger.scoped("feature.spendingCoordinator")

        NavigationStack {
            SpendingChartView()
                .transactionHistoryLogger(
                    coordinatorLogger.scoped("feature.spendingChart")
                )
        }
        .onAppear {
            coordinatorLogger.info("Spending coordinator displayed")
        }
    }
}

#Preview {
    SpendingCoordinatorView()
        .includingMocks()
}
