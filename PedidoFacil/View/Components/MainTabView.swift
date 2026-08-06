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
    @State private var priceListViewModel = PriceListImportViewModel()
    @State private var customerStore = CustomerStore()
    
    var body: some View {
        TabView {
            DailySalesView(
                productModel: productModel,
                priceListViewModel: priceListViewModel,
                customerStore: customerStore
            )
                .tabItem {
                    Label("Início", systemImage: "house")
                }

            PriceListImportView(
                viewModel: priceListViewModel
            )
            .tabItem {
                Label("Listas", systemImage: "list.clipboard")
            }

            OrdersView()
                .tabItem {
                    Label("Pedidos", systemImage: "doc.plaintext")
                }

            CustomerListView(store: customerStore)
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
        .task(id: productReferenceKey) {
            priceListViewModel.updateCatalogReference(
                brands: Array(Set(productModel.products.compactMap(\.brand))),
                categories: Array(Set(productModel.products.map(\.category)))
            )
        }
    }

    private var productReferenceKey: String {
        productModel.products
            .map { "\($0.id.uuidString)|\($0.brand ?? "")|\($0.category)" }
            .sorted()
            .joined(separator: ";")
    }
}
