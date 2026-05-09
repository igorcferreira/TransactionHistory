//
//  CategoryPickerView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 09/05/2026.
//

import SwiftData
import SwiftUI

/// Sheet for quickly assigning a category to a transaction from a notification action.
struct CategoryPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: CategoryPickerViewModel
    var onDismiss: () -> Void

    init(
        transactionID: UUID,
        container: ModelContainer,
        onDismiss: @escaping () -> Void
    ) {
        self._viewModel = State(
            initialValue: CategoryPickerViewModel(
                transactionID: transactionID,
                container: container
            )
        )
        self.onDismiss = onDismiss
    }

    var body: some View {
        NavigationStack {
            List {
                if let transaction = viewModel.transaction {
                    Section {
                        LabeledContent("Transaction", value: viewModel.transactionName)
                        LabeledContent("Amount", value: transaction.formattedAmount)
                    }

                    Section("Category") {
                        ForEach(viewModel.selectableCategories, id: \.self) { category in
                            Button {
                                viewModel.setCategory(category)
                                onDismiss()
                            } label: {
                                HStack {
                                    Text(viewModel.displayName(for: category))
                                    Spacer()
                                    if category == transaction.category {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.tint)
                                    }
                                }
                            }
                            .tint(.primary)
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "Transaction Not Found",
                        systemImage: "exclamationmark.triangle",
                        description: Text("The transaction may have been deleted.")
                    )
                }
            }
            .navigationTitle("Set Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
            }
            .toast(message: $viewModel.errorMessage)
            .onAppear {
                viewModel.loadTransaction()
            }
        }
    }
}

#Preview {
    CategoryPickerView(
        transactionID: UUID(),
        container: DataStorage.createMockEnvironment(),
        onDismiss: {}
    )
}
