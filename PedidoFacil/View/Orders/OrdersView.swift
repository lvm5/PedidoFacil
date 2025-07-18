//
//  OrdersView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-18.
//


import SwiftUI

struct OrdersView: View {
    @EnvironmentObject var viewModel: OrderViewModel
    
    // Cores personalizadas
    private let primaryColor = Color(red: 0.3, green: 0.4, blue: 0.9)
    private let secondaryColor = Color(red: 0.9, green: 0.3, blue: 0.4)
    
    var body: some View {
        ZStack {
           // BackgroundView()
            VStack {
                HeaderView(
                    title: "Lista de pedidos",
                    primaryColor: primaryColor,
                    onClearAll: viewModel.clearAllOrders,
                    isClearDisabled: viewModel.orders.isEmpty
                )
                
                NavigationStack {
                    List {
                        ForEach(viewModel.clientOrders.sorted(by: { $0.date > $1.date })) { order in
                            NavigationLink(destination: OrderDetailView(order: order)) {
                                OrderRowViewChild(order: order)
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.removeClientOrder(at: indexSet)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
    }
}






#Preview {
    let sampleProducts: [Product] = [
        Product(name: "Produto A", purchasePrice: 10.0, sellingPrice: 15.0, packageType: "Unidade", packageSize: "1 un", unitsPerPackage: 1, category: "Categoria A", brand: nil),
        Product(name: "Produto B", purchasePrice: 20.0, sellingPrice: 30.0, packageType: "Unidade", packageSize: "1 un", unitsPerPackage: 1, category: "Categoria B", brand: nil)
    ]
    
    let mockViewModel = OrderViewModel()
    mockViewModel.clientOrders = [
        ClientOrder(clientName: "João", date: Date(), items: [
            OrderItem(product: sampleProducts[0], quantity: 2.0)
        ]),
        ClientOrder(clientName: "Maria", date: Date().addingTimeInterval(-86400), items: [
            OrderItem(product: sampleProducts[1], quantity: 3.0)
        ])
    ]
    return OrdersView()
        .environmentObject(mockViewModel)
}
