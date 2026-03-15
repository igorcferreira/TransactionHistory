//
//  CreateTransactionView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 15/03/2026.
//

import SwiftData
import SwiftUI

/// Form for manually creating a new transaction, presented as a sheet.
struct CreateTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = CreateTransactionViewModel()

    /// Controls whether the user wants to pick a custom date.
    @State private var useCustomDate = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section("Transaction") {
                TextField("Name", text: $viewModel.name)
                TextField("Merchant", text: $viewModel.merchant)
            }

            Section("Amount") {
                TextField("0.00", text: $viewModel.amountText)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                Picker("Currency", selection: $viewModel.currency) {
                    ForEach(
                        CreateTransactionViewModel.commonCurrencies,
                        id: \.self
                    ) { code in
                        Text(CreateTransactionViewModel.currencyLabel(for: code))
                            .tag(code)
                    }
                }
            }

            Section("Details") {
                TextField("Card", text: $viewModel.card)
                Toggle("Custom Date", isOn: $useCustomDate)
                if useCustomDate {
                    DatePicker(
                        "Date",
                        selection: Binding(
                            get: { viewModel.date ?? Date() },
                            set: { viewModel.date = $0 }
                        ),
                        displayedComponents: .date
                    )
                }
            }
        }
        .toast(message: $errorMessage)
        .navigationTitle("New Transaction")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(!viewModel.canSave)
            }
        }
        .onChange(of: useCustomDate) {
            // Clear custom date when toggling off so save uses Date().
            if !useCustomDate {
                viewModel.date = nil
            }
        }
    }

    private func save() {
        Task {
            do {
                try await viewModel.save(
                    in: modelContext.container
                )
                dismiss()
            } catch {
                withAnimation {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateTransactionView()
    }
    .includingMocks()
}
