//
//  AppCoordinatorView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 15/04/2026.
//

import SwiftUI

/// Root coordinator that hosts a TabView with domain-specific coordinators.
public struct AppCoordinatorView: View {
    @State private var viewModel = AppCoordinatorViewModel()

    public init() {}

    public var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("Transactions", systemImage: "list.bullet", value: .transactions) {
                TransactionCoordinatorView()
            }
            Tab("Spending", systemImage: "chart.pie", value: .spending) {
                SpendingCoordinatorView()
            }
        }
    }
}

#Preview {
    AppCoordinatorView()
        .includingMocks()
}
