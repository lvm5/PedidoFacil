//
//  HeaderView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-17.
//


import SwiftUI

struct HeaderView: View {
    let title: String
    let primaryColor: Color
    let onClearAll: () -> Void
    let isClearDisabled: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "bag.fill")
                    .font(.title2)
                    .foregroundColor(primaryColor)
                    .padding(.horizontal)
                
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Divider()
                .padding(.horizontal, 20)
        }
        .background(.ultraThinMaterial)
    }
}

#Preview {
    HeaderView(
        title: "Pedido Fácil",
        primaryColor: Color.blue,
        onClearAll: {},
        isClearDisabled: false
    )
}
