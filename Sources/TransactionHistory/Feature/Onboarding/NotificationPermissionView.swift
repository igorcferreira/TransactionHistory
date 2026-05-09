//
//  NotificationPermissionView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 09/05/2026.
//

import SwiftUI

/// Page 2 of onboarding: explains why notifications matter and requests permission.
struct NotificationPermissionView: View {
    @State private var viewModel = NotificationPermissionViewModel()
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "bell.badge")
                .font(.system(size: 72))
                .foregroundStyle(.tint)

            VStack(spacing: 12) {
                Text("Stay Updated on Your Transactions")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text(
                    "When you log a transaction with Siri, a notification "
                    + "lets you quickly assign a category — so your spending "
                    + "data stays organized without opening the app."
                )
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    Task {
                        await viewModel.requestPermission()
                        onComplete()
                    }
                } label: {
                    Text("Enable Notifications")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(viewModel.isRequesting)

                Button("Not Now", action: onComplete)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    NotificationPermissionView(onComplete: {})
}
