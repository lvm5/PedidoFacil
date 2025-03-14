//
//  OrderFormView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-03-12.
//

import SwiftUI
import SwiftData

struct OrderFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State var order: Order

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Cliente")) {
                    TextField("Nome", text: $order.customerName)
                    TextField("Telefone", text: $order.customerPhone)
                }

                Section(header: Text("Produtos")) {
                    ForEach(order.items) { item in
                        HStack {
                            Text(item.productName)
                            Spacer()
                            Text("\(item.quantity) x R$ \(NSDecimalNumber(decimal: item.price).doubleValue, specifier: "%.2f")")
                        }
                    }
                }
            }
            .navigationTitle(order.id == nil ? "Novo Pedido" : "Editar Pedido")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Salvar") {
                        saveOrder()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveOrder() {
        if order.id == nil {
            modelContext.insert(order)
        }
        dismiss()
    }
}