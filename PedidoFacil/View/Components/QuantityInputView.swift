//
//  QuantityInputView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-17.
//


import SwiftUI

struct QuantityInputView: View {
    @Binding var quantityKg: String
    var primaryColor: Color

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "scalemass.fill")
                    .foregroundColor(primaryColor)
                Text("Quantidade")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            TextField("0.00", text: $quantityKg)
                .keyboardType(.decimalPad)
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(primaryColor.opacity(0.1), lineWidth: 1)
                )
            
            Text("Digite a quantidade em kg")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
 

/// PREVIEW
struct QuantityInputView_Previews: PreviewProvider {
    @State static var previewQuantity = "1.50"
    
    static var previews: some View {
        QuantityInputView(quantityKg: $previewQuantity, primaryColor: .blue)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
