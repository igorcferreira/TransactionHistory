//
//  WelcomeView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 09/05/2026.
//

import SwiftUI

/// Page 1 of onboarding: introduces the app's core functionality.
struct WelcomeView: View {
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "wallet.bifold.fill")
                .font(.system(size: 72))
                .foregroundStyle(.tint)

            VStack(spacing: 12) {
                Text("Track Your Transactions")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text(
                    "Keep a record of your purchases, organize them by category, "
                    + "and log transactions on the go with Siri Shortcuts."
                )
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            Spacer()

            Button(action: onContinue) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    WelcomeView(onContinue: {})
}
