//
//  MainTabView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-18.
//


import SwiftUI

@available(iOS 26.0, *)
struct MainTabView: View {
    @EnvironmentObject var viewModel: OrderViewModel
    
    var body: some View {
        TabView {
            HomeView() // separado
                .tabItem {
                    Label("Início", systemImage: "house")
                }
            
            OrdersView() // separado
                .tabItem {
                    Label("Pedidos", systemImage: "doc.plaintext")
                }
            
            PurchaseSuggestionsView() // agrupado
                .tabItem {
                    Label("Compra", systemImage: "shippingbox")
                }

            ProductsView() // agrupado
                .tabItem {
                    Label("Produtos", systemImage: "cart")
                }

            ProfitView() // agrupado
                .tabItem {
                    Label("Lucros", systemImage: "chart.bar")
                }
        }
    }
}

