//
//  ToastView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 15/03/2026.
//

import SwiftUI

/// A toast overlay that slides up from the bottom and auto-dismisses.
private struct ToastModifier: ViewModifier {
    @Binding var message: String?

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottom) {
            if let message {
                Text(message)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onTapGesture { dismiss() }
            }
        }
        .animation(.easeInOut, value: message)
        .task(id: message) {
            guard message != nil else { return }
            try? await Task.sleep(for: .seconds(3))
            dismiss()
        }
    }

    private func dismiss() {
        withAnimation {
            message = nil
        }
    }
}

extension View {
    /// Presents a temporary toast message at the bottom of the view.
    func toast(message: Binding<String?>) -> some View {
        modifier(ToastModifier(message: message))
    }
}
