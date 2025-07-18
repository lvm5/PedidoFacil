//
//  OrderRowView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-18.
//


import SwiftUI

struct OrderRowViewChild: View {
    var order: ClientOrder

    var body: some View {
        VStack(alignment: .leading) {
            Text(order.clientName)
                .font(.headline)
            Text("Data: \(order.date.formatted(date: .numeric, time: .omitted))")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("💰 Total: R$ \(String(format: "%.2f", order.totalPrice))")
                .font(.subheadline)
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
    }
}








#Preview {
    OrderRowViewChild(order: ClientOrder(
        clientName: "João da Silva",
        date: Date(),
        items: [
            OrderItem(product: Product(
                name: "Coxinha",
                purchasePrice: 12.79,
                sellingPrice: 15.29,
                packageType: "Kg",
                packageSize: "1kg",
                unitsPerPackage: 1,
                category: "Aves",
                brand: nil
            ), quantity: 2)
        ]
    ))
}

