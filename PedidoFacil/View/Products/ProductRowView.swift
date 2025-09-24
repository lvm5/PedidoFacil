//
//  ProductRowView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-18.
//
import Foundation
import Swift
import SwiftUI

@available(iOS 26.0, *)
struct ProductRowView: View {
    @EnvironmentObject var productModel: ProductModel
    @EnvironmentObject var viewModel: OrderViewModel
    @State var product: Product
    @State private var purchasePrice: Double
    @State private var sellingPrice: Double
    let secondaryColor: Color
    
    init(product: Product, secondaryColor: Color) {
        _product = State(initialValue: product)
        _purchasePrice = State(initialValue: product.purchasePrice)
        _sellingPrice = State(initialValue: product.sellingPrice)
        self.secondaryColor = secondaryColor
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(product.name)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.primary)

                    Text(product.brand ?? "")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    product.purchasePrice = purchasePrice
                    product.sellingPrice = sellingPrice
                    productModel.update(product)
                    viewModel.selectedProduct = product
                }) {
                    Text("Editar")
                        .frame(maxWidth: 80, maxHeight: 40)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(secondaryColor)
                        .cornerRadius(10)
                }
            }
        }
    }
}

@available(iOS 26.0, *)
#Preview {
    ProductRowView(
        product: Product(
            name: "Produto Teste",
            purchasePrice: 10.0,
            sellingPrice: 15.0,
            packageType: "Pacote",
            packageSize: "1kg",
            unitsPerPackage: 1,
            category: "Teste"
        ),
        secondaryColor: .purple
    )
    .environmentObject(ProductModel())
    .environmentObject(OrderViewModel())
    .padding()
    .previewLayout(.sizeThatFits)
}
