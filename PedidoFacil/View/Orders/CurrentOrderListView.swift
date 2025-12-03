//
//  CurrentOrderListView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-18.
//

import Foundation
import Swift
import SwiftUI

struct CurrentOrderListView: View {
    let orders: [OrderItem]
    let primaryColor: Color
    let removeOrder: (OrderItem) -> Void

    var body: some View {
        GroupBox {
            VStack {
                ForEach(orders) { order in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(order.product.name)
                                .fontWeight(.semibold)

                            if let brand = order.product.brand {
                                Text("Marca: \(brand)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Text("Quantidade: \(String(format: "%.2f", order.quantity)) \(order.product.packageType)")
                                .font(.caption)

                            Text("Total: R$ \(String(format: "%.2f", order.totalPrice))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(role: .destructive, action: { removeOrder(order) }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    //.background(Material.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}


#Preview {
    ScrollView {
        CurrentOrderListView(
            orders: [
                OrderItem(
                    product: Product(
                        name: "Arroz",
                        purchasePrice: 5.0,
                        sellingPrice: 7.0,
                        packageType: "Kg",
                        packageSize: "1kg",
                        unitsPerPackage: 1,
                        category: "Grãos",
                        brand: "Tio João"
                    ),
                    quantity: 2.5
                )
            ],
            primaryColor: .blue,
            removeOrder: { _ in }
        )
        .padding()
    }
}

