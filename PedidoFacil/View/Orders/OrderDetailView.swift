//
//  OrderDetailView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-18.
//


import SwiftUI

struct OrderDetailView: View {
    var order: ClientOrder
    
    // Computed property para receber o texto formatado do pedido
    var receiptText: String {
        var receipt = "Pedido para: \(order.clientName)\n\n"
        for item in order.items {
            receipt += "- \(item.product.name) \(item.product.brand ?? ""): \(String(format: "%.2f", item.quantity))kg - R$ \(String(format: "%.2f", item.totalPrice))\n"
        }
        receipt += "\nTotal: R$ \(String(format: "%.2f", order.totalPrice))"
        return receipt
    }

    var body: some View {
        List {
            Section(header: Text("Cliente")) {
                Text(order.clientName)
            }

            Section(header: Text("Itens")) {
                ForEach(order.items) { item in
                    VStack(alignment: .leading) {
                        Text("\(item.product.name) \(item.product.brand ?? "")")
                        Text("Quantidade: \(item.quantity, specifier: "%.2f") kg")
                        Text("Total: R$ \(item.totalPrice, specifier: "%.2f")")
                    }
                }
            }

            Section(header: Text("Resumo")) {
                Text("💰 Total: R$ \(order.totalPrice, specifier: "%.2f")")
            }
            
            // Nova seção para o botão de compartilhar
            Section {
                ShareLink(item: receiptText) {
                    Label("Compartilhar Pedido", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Detalhes")
    }
}

#Preview {
    let sampleProduct = Product(
        name: "Coxinha",
        purchasePrice: 10.0,
        sellingPrice: 15.0,
        packageType: "Kg",
        packageSize: "1kg",
        unitsPerPackage: 1,
        category: "Aves",
        brand: "Seara"
    )

    let sampleItem = OrderItem(product: sampleProduct, quantity: 2)
    let sampleOrder = ClientOrder(
        clientName: "João da Silva", date: Date(),
        items: [sampleItem]
    )

    NavigationStack {
        OrderDetailView(order: sampleOrder)
    }
}
