//
//  OrderListView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-17.
//

import SwiftUI

struct OrderListView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let orders: [ClientOrder]
    let primaryColor: Color
    let removeOrder: (ClientOrder) -> Void
    
    var body: some View {
        
        
        
        VStack(alignment: .leading ,spacing: 16) {
            HStack {
                Image(systemName: "list.clipboard.fill")
                    .foregroundColor(primaryColor)
                Text("Pedidos (\(orders.count))")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                ForEach(orders) { order in
                    OrderRowView(order: order)
                        .swipeActions {
                            Button(role: .destructive) {
                                removeOrder(order)
                            } label: {
                                Label("Excluir", systemImage: "trash.fill")
                            }
                        }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    OrderListView(
        orders: [
            ClientOrder(
                clientName: "João Silva",
                date: Date(),
                items: []
            )
        ],
        primaryColor: .blue,
        removeOrder: { _ in }
    )
    .padding()
    .previewLayout(.sizeThatFits)
}
