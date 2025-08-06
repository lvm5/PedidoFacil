//
//  ProductSelectionView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-17.
//

import Foundation
import Swift
import SwiftUI

struct ProductSelectionView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var productModel: ProductModel
    
    @Binding var selectedProduct: Product
    @Binding var showingCalculation: Bool

    
    var body: some View {
        // MARK: - Product Selection Section
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "cart.fill")
                        .foregroundColor(.accentColor)
                    Text("Selecionar Produto")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                Menu {
                    ForEach(productModel.products.sorted(by: { $0.category < $1.category })) { product in
                        Button(action: {
                            selectedProduct = product
                            withAnimation(.spring()) {
                                showingCalculation = false
                            }
                        }) {
                            VStack(alignment: .leading) {
                                Text("\(product.name)  \(product.brand ?? "")")
                                if let brand = product.brand {
                                    Text(brand)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Text(product.category)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(selectedProduct.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if let brand = selectedProduct.brand {
                                Text(brand)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(selectedProduct.category)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        }
    }

#Preview {
    ProductSelectionView(
        selectedProduct: .constant(sampleProducts.first ?? Product(name: "Produto Exemplo", purchasePrice: 0, sellingPrice: 0, packageType: "", packageSize: "", unitsPerPackage: 0, category: "")),
        showingCalculation: .constant(false)
    )
}
