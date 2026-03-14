//
//  TransactionListView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 12/03/2026.
//
import Foundation
import SwiftUI
import SwiftData

public struct TransactionListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TransactionListViewModel()

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            TransactionListHeaderView(
                searchText: $viewModel.searchText,
                sortOrder: $viewModel.sortOrder
            )
            TransactionListGroupView(
                search: viewModel.searchText,
                sortOrder: viewModel.sortOrder
            )
        }
    }
}

#Preview {
    TransactionListView()
        .includingMocks()
}
