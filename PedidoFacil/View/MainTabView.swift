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
            HomeView()
                .tabItem {
                    Label("Início", systemImage: "house")
                }
            
            OrdersView()
                .tabItem {
                    Label("Pedidos", systemImage: "doc.plaintext")
                }
            
            PurchaseSuggestionsView(primaryColor: .blue)
                .tabItem {
                    Label("Compra", systemImage: "shippingbox")
                }

            ProductsView()
                .tabItem {
                    Label("Produtos", systemImage: "cart")
                }

            ProfitView()
                .tabItem {
                    Label("Lucros", systemImage: "chart.bar")
                }
        }
    }
}

