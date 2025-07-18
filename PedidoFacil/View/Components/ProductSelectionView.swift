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
    
    @Binding var selectedProduct: Product
    @Binding var showingCalculation: Bool

    
    private let primaryColor = Color(red: 0.3, green: 0.4, blue: 0.9)
    private let secondaryColor = Color(red: 0.9, green: 0.3, blue: 0.4)
    
    var body: some View {
        // MARK: - Product Selection Section
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "cart.fill")
                        .foregroundColor(primaryColor)
                    Text("Selecionar Produto")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                Menu {
                    ForEach(sampleProducts.sorted(by: { $0.category < $1.category })) { product in
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
