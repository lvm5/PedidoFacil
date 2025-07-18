//
//  ProductsView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-18.
//

import SwiftUI

@available(iOS 26.0, *)
struct ProductsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var productModel: ProductModel
    @EnvironmentObject var viewModel: OrderViewModel
    
    // Cores personalizadas
    private let primaryColor = Color(red: 0.3, green: 0.4, blue: 0.9)
    private let secondaryColor = Color(red: 0.9, green: 0.3, blue: 0.4)
    
    var body: some View {
        VStack {
            HeaderView(
                title: "Lista de produtos",
                primaryColor: primaryColor,
                onClearAll: viewModel.clearAllOrders,
                isClearDisabled: viewModel.orders.isEmpty
            )
            
            // Seção de preços
            if let index = productModel.products.firstIndex(where: { $0.id == viewModel.selectedProduct.id }) {
                PriceInfoView(
                    product: $productModel.products[index],
                    secondaryColor: secondaryColor)
            }
            List {
                ForEach(productModel.products) { product in
                    ProductRowView(product: product, secondaryColor: secondaryColor)
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        let product = productModel.products[index]
                        productModel.delete(product)
                    }
                }
            }
        }
    }
}

@available(iOS 26.0, *)
#Preview {
    ProductsView()
        .environmentObject(ProductModel())
        .environmentObject(OrderViewModel())
}
