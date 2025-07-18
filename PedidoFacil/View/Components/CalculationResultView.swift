//
//  CalculationResultView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-17.
//


import SwiftUI

struct CalculationResultView: View {
    let totalPrice: Double
    let totalProfit: Double

    var body: some View {
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
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}