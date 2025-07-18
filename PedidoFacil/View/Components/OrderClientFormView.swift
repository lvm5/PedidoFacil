//
//  OrderClientFormView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-17.
//


import SwiftUI

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
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

