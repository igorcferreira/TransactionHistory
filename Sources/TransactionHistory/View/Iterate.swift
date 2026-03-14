//
//  Iterate.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 14/03/2026.
//
import SwiftUI

struct Iterate<V: Identifiable & Hashable, Content: View>: View {
    @ViewBuilder
    let contentBuilder: (V) -> Content
    let items: Array<EnumeratedSequence<[V]>.Element>
    
    init(
        _ items: EnumeratedSequence<[V]>,
        @ViewBuilder contentBuilder: @escaping (V) -> Content
    ) {
        self.items = Array(items)
        self.contentBuilder = contentBuilder
    }
    
    init(
        _ items: Array<EnumeratedSequence<[V]>.Element>,
        @ViewBuilder contentBuilder: @escaping (V) -> Content
    ) {
        self.items = items
        self.contentBuilder = contentBuilder
    }
    
    var body: some View {
        ForEach(items, id: \.element) { index, transaction in
            contentBuilder(transaction)
                .id("\(transaction.id)_\(index)")
        }
    }
}
