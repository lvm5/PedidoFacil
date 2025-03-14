//
//  RequestedProductsView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-03-12.
//


import Foundation
import SwiftUI
import SwiftData

struct RequestedProductsView: View {
	// Consulta todos os pedidos cadastrados no SwiftData
	@Query private var orders: [Order]
	
	// Armazena o peso da caixa para cada produto (chave: nome do produto, valor: texto digitado)
	@State private var boxWeights: [String: String] = [:]
	
	// Calcula o total solicitado para cada produto (em kg) a partir dos pedidos
	// Apenas itens com quantidade > 0 são considerados
	var productsSummary: [String: Decimal] {
		var summary: [String: Decimal] = [:]
		for order in orders {
			for item in order.items where item.quantity > 0 {
				summary[item.name, default: Decimal(0)] += item.quantity
			}
		}
		return summary
	}
	
	var body: some View {
		ScrollView {
			VStack(spacing: 20) {
				Text("Produtos Solicitados")
					.font(.title)
					.padding()
				
				if !productsSummary.isEmpty {
					VStack(alignment: .leading, spacing: 15) {
						ForEach(productsSummary.keys.sorted(), id: \.self) { product in
							HStack {
								Text(product)
									.frame(width: 150, alignment: .leading)
								let totalRequested = productsSummary[product] ?? 0
								Text("Total: \(NSDecimalNumber(decimal: totalRequested).doubleValue, specifier: "%.2f")kg")
									.frame(width: 120, alignment: .leading)
								TextField("Peso Caixa", text: Binding(
									get: { boxWeights[product] ?? "" },
									set: { boxWeights[product] = $0 }
								))
								.textFieldStyle(.roundedBorder)
								.keyboardType(.decimalPad)
								.frame(width: 80)
								let boxWeight = Decimal(string: boxWeights[product] ?? "") ?? 0
								let difference = boxWeight - totalRequested
								Text("Falta: \(NSDecimalNumber(decimal: difference).doubleValue, specifier: "%.2f")kg")
									.frame(width: 120, alignment: .leading)
							}
						}
					}
					.padding()
					.background(Color(.systemGray6))
					.cornerRadius(8)
					.padding(.horizontal)
				} else {
					Text("Nenhum produto solicitado ainda.")
				}
			}
		}
		.navigationTitle("Produtos Solicitados")
	}
}
