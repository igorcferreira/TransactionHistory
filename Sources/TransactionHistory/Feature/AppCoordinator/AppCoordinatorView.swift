//
//  AppCoordinatorView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 15/04/2026.
//

import SwiftData
import SwiftUI

/// Root coordinator that hosts a TabView with domain-specific coordinators.
/// Gates the main UI behind a one-time onboarding flow.
public struct AppCoordinatorView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.notificationRouter) private var notificationRouter
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var viewModel = AppCoordinatorViewModel()

    public init() {}

    public var body: some View {
        if hasCompletedOnboarding {
            mainContent
            .sheet(
                item: Binding(
                    get: { notificationRouter.pendingCategoryTransactionID.map(PendingTransaction.init) },
                    set: { notificationRouter.pendingCategoryTransactionID = $0?.id }
                )
            ) { pending in
                CategoryPickerView(
                    transactionID: pending.id,
                    container: modelContext.container,
                    onDismiss: { notificationRouter.pendingCategoryTransactionID = nil }
                )
            }
            .onChange(of: notificationRouter.pendingDetailTransactionID) {
                guard notificationRouter.pendingDetailTransactionID != nil else { return }
                viewModel.selectedTab = .transactions
            }
        } else {
            OnboardingCoordinatorView {
                hasCompletedOnboarding = true
            }
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if horizontalSizeClass == .compact {
            tabbedContent
        } else {
            sideBySideContent
        }
    }
    
    @ViewBuilder
    private var tabbedContent: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("Transactions", systemImage: "list.bullet", value: .transactions) {
                TransactionCoordinatorView()
            }
            Tab("Spending", systemImage: "chart.pie", value: .spending) {
                SpendingCoordinatorView()
            }
        }
    }
    
    @ViewBuilder
    private var sideBySideContent: some View {
        if #available(anyAppleOS 27.1, *) {
            ArrangementView {
                SpendingCoordinatorView()
            } secondary: {
                TransactionCoordinatorView()
            }
        } else {
            tabbedContent
        }
    }
}

/// Identifiable wrapper so `.sheet(item:)` can be driven by a UUID.
private struct PendingTransaction: Identifiable {
    let id: UUID
}

#Preview {
    AppCoordinatorView()
        .includingMocks()
}
