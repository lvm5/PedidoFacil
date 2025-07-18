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
    let secondaryColor: Color
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                Text(product.name)
                    .font(.headline)
                Text(product.brand ?? "")
                    .font(.headline)
            }
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Compra:")
                        Spacer()
                        TextField("Preço de compra", value: $product.purchasePrice, format: .number)
                            .frame(width: 100)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }
                   
                    
                    HStack {
                        Text("Venda:")
                        Spacer()
                        TextField("Preço de venda", value: $product.sellingPrice, format: .number)
                            .frame(width: 100)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                Spacer()
                
                Button(action: {
                    productModel.update(product)
                    viewModel.selectedProduct = product
                }) {
                    Text("Salvar")
                        .frame(maxWidth: 80, maxHeight: 40)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(secondaryColor)
                        .cornerRadius(10)
                }
            }
        }
        //.glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
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
