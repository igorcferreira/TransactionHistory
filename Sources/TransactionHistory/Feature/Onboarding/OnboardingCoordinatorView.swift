//
//  OnboardingCoordinatorView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 09/05/2026.
//

import SwiftUI

/// Two-screen onboarding coordinator: Welcome → Notification Permission → Complete.
struct OnboardingCoordinatorView: View {
    @State private var viewModel = OnboardingCoordinatorViewModel()
    var onComplete: () -> Void

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            WelcomeView(onContinue: viewModel.showNotificationPermission)
                .navigationDestination(for: OnboardingCoordinatorViewModel.Page.self) { page in
                    switch page {
                    case .welcome:
                        WelcomeView(onContinue: viewModel.showNotificationPermission)
                    case .notifications:
                        NotificationPermissionView(onComplete: onComplete)
                    }
                }
        }
    }
}

#Preview {
    OnboardingCoordinatorView(onComplete: {})
}
