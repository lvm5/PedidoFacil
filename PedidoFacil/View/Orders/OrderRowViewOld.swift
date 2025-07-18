//
//  OrderRowView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-17.
//

//import SwiftUI

/// View que exibe um item de pedido com nome do produto, quantidade, valor total e lucro.
//struct OrderRowView: View {
//    let item: OrderItem
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(item.product.name + (item.product.brand != nil ? " - \(item.product.brand!)" : ""))
//                .font(.headline)
//            
//            HStack {
//                Text("Qtd: \(item.quantity, specifier: "%.1f") kg")
//                Spacer()
//                Text("💵 \(item.totalPrice, format: .currency(code: "BRL"))")
//            }
//            .font(.subheadline)
//            .foregroundStyle(.secondary)
//            
//            Text("Lucro: \(item.totalProfit, format: .currency(code: "BRL"))")
//                .font(.caption)
//                .foregroundStyle(.green)
//        }
//        .padding(.vertical, 6)
//    }
//}

//#Preview {
//    OrderRowView(item: OrderItem(
//        product: sampleProducts[0],
//        quantity: 5.0
//    ))
//}
