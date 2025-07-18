//
//  PriceInfoView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-17.
//


import SwiftUI

struct PriceInfoView: View {
   @Binding var product: Product
    var secondaryColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Compra
            VStack(spacing: 8) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("Compra")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("R$ \(product.purchasePrice, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("por \(product.packageSize)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

            // Venda
            VStack(spacing: 8) {
                Image(systemName: "banknote.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                Text("Venda")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("R$ \(product.sellingPrice, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("por \(product.packageSize)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

            // Margem
            VStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundColor(secondaryColor)
                
                Text("Margem")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("R$ \(product.sellingPrice - product.purchasePrice, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("\(((product.sellingPrice - product.purchasePrice) / product.purchasePrice * 100), specifier: "%.1f")%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}
