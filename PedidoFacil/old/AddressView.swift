////
////  AddressView.swift
////  PedidoFacil
////
////  Created by Leandro Morais on 2025-03-12.
////
//
//
//import SwiftUI
//
//struct AddressView: View {
//  @Bindable var order: Order
//  var body: some View {
//	Form {
//	  Section {
//		TextField("Nome", text: $order.name)
//	  }
//
//	  Section {
//		NavigationLink("Enviar pedido") {
//		  CheckoutView(order: order)
//		}
//	  }
//	  .disabled(order.hasValidItens == false)
//	}
//	.navigationTitle("Detalhes do envio")
//	.navigationBarTitleDisplayMode(.inline)
//  }
//}
