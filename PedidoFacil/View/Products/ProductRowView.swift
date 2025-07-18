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
            Text(product.name)
                .font(.headline)
            //GlassEffectContainer {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Compra:")
                            TextField("Preço de compra", value: $product.purchasePrice, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        HStack {
                            Text("Venda:")
                            TextField("Preço de venda", value: $product.sellingPrice, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    
                    Button(action: {
                        productModel.update(product)
                        viewModel.selectedProduct = product
                    }) {
                        Text("Salvar")
                            .frame(maxWidth: 80, maxHeight: .infinity)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(secondaryColor)
                            .cornerRadius(10)
                    }
                }
            //}
            //.glassEffect(.regular, in: .rect(cornerRadius: 24))
        }
    }
}
//}
