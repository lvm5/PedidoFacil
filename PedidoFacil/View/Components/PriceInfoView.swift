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




#if DEBUG
struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    var content: (Binding<Value>) -> Content
    init(_ initialValue: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: initialValue)
        self.content = content
    }
    var body: some View {
        content($value)
    }
}

#Preview {
    StatefulPreviewWrapper(Product(
        name: "Arroz",
        purchasePrice: 20.0,
        sellingPrice: 25.0,
        packageType: "Pacote",
        packageSize: "5kg",
        unitsPerPackage: 1,
        category: "Alimentos"
    )) { product in
        PriceInfoView(product: product, secondaryColor: .purple)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif




