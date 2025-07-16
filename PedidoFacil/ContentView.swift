//
//  ContentView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-15.
//

import SwiftUI

@available(iOS 26.0, *)
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var quantityKg: String = ""
    @State private var totalPrice: Double = 0.0
    @State private var totalProfit: Double = 0.0
    
    let product = sampleProducts[0]
    
    var body: some View {
        ZStack {
            if #available(iOS 18.0, *) {
                MeshGradient(
                    width: 4, // Número de segmentos horizontais
                    height: 8, // Número de segmentos verticais
                    points: [
                        // Ajuste os pontos para controlar a forma da malha
                        // Tente movimentar os pontos ligeiramente para diferentes efeitos
                        .init(0, 0.01), .init(0.5, 0.0), .init(1.0, 0.0),
                        .init(0.5, 1.0), .init(0.7, 0.5), .init(1.0, 0.7),
                        .init(0.0, 1.01), .init(0.0, 0.5), .init(0.0, 0.5)
                    ],
                    colors: [
                        // Cores pastéis personalizadas com baixa opacidade para um efeito suave
                        Color(red: 0.9, green: 0.7, blue: 0.8).opacity(0.9), // Rosa pálido
                        Color(red: 0.7, green: 0.8, blue: 0.9).opacity(0.9), // Azul claro
                        Color(red: 0.8, green: 0.9, blue: 0.7).opacity(0.9), // Verde menta
                        
                        Color(red: 0.95, green: 0.85, blue: 0.7).opacity(0.9), // Pêssego claro
                        Color(red: 0.8, green: 0.75, blue: 0.9).opacity(0.9), // Lilás
                        Color(red: 0.7, green: 0.9, blue: 0.95).opacity(0.9), // Azul água
                        
                        Color(red: 0.9, green: 0.9, blue: 0.75).opacity(0.9), // Amarelo baunilha
                        Color(red: 0.85, green: 0.7, blue: 0.7).opacity(0.9), // Coral suave
                        Color(red: 0.75, green: 0.95, blue: 0.85).opacity(0.9) // Verde claro azulado
                    ]
                )
                .ignoresSafeArea()
                // Uma sombra sutil pode adicionar profundidade, mas use com moderação em pastéis
                .shadow(color: Color.gray.opacity(0.1), radius: 15, x: 5, y: 5)
            } else {
                // Fallback para versões anteriores (iOS < 17.0)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.9, green: 0.7, blue: 0.8).opacity(0.7), // Rosa pálido
                        Color(red: 0.7, green: 0.8, blue: 0.9).opacity(0.7)  // Azul claro
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            GlassEffectContainer{
                VStack(spacing: 20) {
                    Text("Produto: \(product.name)")
                        .font(.title2)
                        .bold()
                    
                    Group {
                        Text("Preço de venda: R$ \(product.sellingPrice, specifier: "%.2f")")
                        Text("Preço de compra: R$ \(product.purchasePrice, specifier: "%.2f")")
                    }
                    .frame(width: 330, height: 80)
                    .padding()
                    .glassEffect(in: RoundedRectangle(cornerRadius: 24))
                    
                    TextField("Quantidade em kg", text: $quantityKg)
                        .keyboardType(.decimalPad)
                    //.textFieldStyle(.roundedBorder)
                        .padding()
                        .glassEffect(.regular, in: .rect(cornerRadius: 16))
                    
                    Button("Calcular") {
                        calculate()
                    }
                    .buttonStyle(.glass)
                    
                    Group {
                        Text("💰 Total: R$ \(totalPrice, specifier: "%.2f")")
                            .font(.title3)
                            //.foregroundStyle(.secondary)
                            .bold()
                            .multilineTextAlignment(.center)
                        Text("📈 Lucro: R$ \(totalProfit, specifier: "%.2f")")
                            .font(.title3)
                            //.foregroundStyle(.secondary)
                            .bold()
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 330, height: 80)
                    .padding()
                    .glassEffect(in: RoundedRectangle(cornerRadius: 24))
                }
            }
            .padding()
        }
    }
    
    func calculate() {
        guard let kg = Double(quantityKg) else {
            print("Quantidade inválida")
            return
        }
        
        totalPrice = kg * product.sellingPrice
        totalProfit = kg * (product.sellingPrice - product.purchasePrice)
    }
}

//#Preview {
//    ContentView()
//}
