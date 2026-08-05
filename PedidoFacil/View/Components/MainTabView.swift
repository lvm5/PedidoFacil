//
//  MainTabView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-18.
//


import SwiftUI

@available(iOS 18.0, *)
struct MainTabView: View {
    @EnvironmentObject var viewModel: OrderViewModel
    @EnvironmentObject var productModel: ProductModel
    
    var body: some View {
        TabView {
            DailySalesView(products: productModel.products)
                .tabItem {
                    Label("Início", systemImage: "house")
                }

            PriceListImportView(
                viewModel: PriceListImportViewModel(
                    knownBrands: Array(Set(productModel.products.compactMap(\.brand))),
                    knownCategories: Array(Set(productModel.products.map(\.category)))
                )
            )
            .tabItem {
                Label("Listas", systemImage: "list.clipboard")
            }

            OrdersView()
                .tabItem {
                    Label("Pedidos", systemImage: "doc.plaintext")
                }

            CustomerListView(store: CustomerStore())
                .tabItem {
                    Label("Clientes", systemImage: "person.2")
                }

//            PurchaseSuggestionsView(primaryColor: .blue)
//                .tabItem {
//                    Label("Compra", systemImage: "shippingbox")
//                }

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
