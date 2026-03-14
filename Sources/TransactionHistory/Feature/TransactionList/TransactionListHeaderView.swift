//
//  TransactionListHeaderView.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import SwiftUI

/// Header containing search and sort controls for the transaction list.
struct TransactionListHeaderView: View {
    @Binding var searchText: String
    @Binding var sortOrder: SortOrder

    var body: some View {
        VStack(spacing: 8) {
            SearchFieldView(text: $searchText)
            SortPickerView(sortOrder: $sortOrder)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Inline search field

private struct SearchFieldView: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search by merchant", text: $text)
                .textFieldStyle(.plain)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Sort order picker

private struct SortPickerView: View {
    @Binding var sortOrder: SortOrder

    var body: some View {
        Picker("Sort", selection: $sortOrder) {
            Text("Newest First").tag(SortOrder.reverse)
            Text("Oldest First").tag(SortOrder.forward)
        }
        .pickerStyle(.segmented)
    }
}
