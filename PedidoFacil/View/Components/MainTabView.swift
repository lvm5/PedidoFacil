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
    @State private var fastOrderViewModel = FastOrderViewModel(products: [])
    
    var body: some View {
        TabView {
            DailySalesView(
                productModel: productModel,
                priceListViewModel: priceListViewModel,
                customerStore: customerStore,
                fastOrderViewModel: fastOrderViewModel
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

            NavigationStack {
                SalesOrderHistoryView(
                    viewModel: fastOrderViewModel,
                    customerProvider: { customerStore.activeCustomers },
                    productProvider: { productModel.products }
                )
            }
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

        }
        .task(id: productReferenceKey) {
            priceListViewModel.updateCatalogReference(
                brands: Array(Set(productModel.products.compactMap(\.brand))),
                categories: Array(Set(productModel.products.map(\.category)))
            )
            fastOrderViewModel.updateProducts(productModel.products)
        }
        .task(id: customerReferenceKey) {
            fastOrderViewModel.updateCustomers(customerStore.activeCustomers)
        }
    }

    private var productReferenceKey: String {
        productModel.products
            .map { "\($0.id.uuidString)|\($0.brand ?? "")|\($0.category)" }
            .sorted()
            .joined(separator: ";")
    }

    private var customerReferenceKey: String {
        customerStore.activeCustomers
            .map { "\($0.id.uuidString)|\($0.name)|\($0.updatedAt.timeIntervalSinceReferenceDate)" }
            .joined(separator: ";")
    }
}
