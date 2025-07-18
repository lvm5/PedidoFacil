//
//  ActionButtonsView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-17.
//


import SwiftUI

struct ActionButtonsView: View {
    var quantityKg: String
    var totalPrice: Double
    var totalProfit: Double
    var showingCalculation: Bool
    var onCalculate: () -> Void
    var onAddOrder: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button(action: onCalculate) {
                HStack {
                    Image(systemName: "plus.square.fill.on.square.fill")
                        .font(.title3)
                    Text("Adicionar item")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.vertical, 6)
            .disabled(quantityKg.isEmpty)

            if showingCalculation {
                VStack(spacing: 12) {
                    Text("Resultado do Cálculo")
                        .font(.headline)
                        .fontWeight(.semibold)

                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("Total")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("R$ \(totalPrice, specifier: "%.2f")")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }

                        VStack(spacing: 4) {
                            Text("Lucro")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("R$ \(totalProfit, specifier: "%.2f")")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .transition(.move(edge: .top).combined(with: .opacity))

                Button(action: onAddOrder) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Adicionar ao Pedido")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.vertical, 6)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        ActionButtonsView(quantityKg: "", totalPrice: 0.0, totalProfit: 0.0, showingCalculation: true, onCalculate: {}, onAddOrder: {})
    } else {
        Text("Preview not available")
    }
}
