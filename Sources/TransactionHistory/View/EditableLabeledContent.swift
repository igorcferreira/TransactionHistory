//
//  EditableLabeledContent.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 13/04/2026.
//
import SwiftUI

struct EditableLabeledContent: View {
    let label: String
    @Binding var text: String

    init(
        _ label: String,
        text: Binding<String>
    ) {
        self.label = label
        self._text = text
    }

    var body: some View {
        HStack(spacing: 4.0) {
            Text("\(label):")
            TextField(label, text: $text)
        }
    }
}

#Preview {
    @Previewable @State var text: String = "Hello World"
    EditableLabeledContent("Name", text: $text)
        .padding()
}
