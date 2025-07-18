//
//  OrderClientFormView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-17.
//


import SwiftUI

@available(iOS 26.0, *)
struct OrderClientFormView: View {
    @Binding var clientName: String
    let orders: [OrderItem]
    var onSave: (ClientOrder) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack{
                Button("Salvar Pedido e Gerar Mensagem") {
                    let clientOrder = ClientOrder(clientName: clientName, date: Date(), items: orders)
                    onSave(clientOrder)
                }
                .bold()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, minHeight: 80)
                .background(Color.mint)
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
}


@available(iOS 26.0, *)
#Preview {
    OrderClientFormView(
        clientName: .constant("Leandro Morais"),
        orders: [
            OrderItem(
                product: Product(
                    name: "Produto Exemplo",
                    purchasePrice: 10.0,
                    sellingPrice: 15.0,
                    packageType: "Kg",
                    packageSize: "1kg",
                    unitsPerPackage: 1,
                    category: "Categoria"
                ),
                quantity: 3
            )
        ],
        onSave: { clientOrder in
            print("Pedido salvo para \(clientOrder.clientName) com \(clientOrder.items.count) itens.")
        }
    )
}
