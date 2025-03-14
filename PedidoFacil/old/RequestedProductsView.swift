////
////  RequestedProductsView.swift
////  PedidoFacil
////
////  Created by Leandro Morais on 2025-03-12.
////
//
//import Foundation
//import SwiftUI
//import SwiftData
//
//struct RequestedProductsView: View {
//	// Consulta todos os pedidos cadastrados no SwiftData
//	@Query private var orders: [Order]
//	// Armazena os pesos da caixa (capacidade) para cada produto (aqui usamos @State para simplicidade)
//	@State private var boxWeights: [String: String] = [:]
//	
//	// Calcula o total solicitado para cada produto (em kg) a partir dos pedidos
//	// Apenas itens com quantidade > 0 são considerados
//	var productsSummary: [String: Decimal] {
//		var summary = [String: Decimal]()
//		for order in orders {
//			for item in order.items where item.quantity > 0 {
//				let key = item.name
//				let qty = item.quantity
//				if let current = summary[key] {
//					summary[key] = current + qty
//				} else {
//					summary[key] = qty
//				}
//			}
//		}
//		return summary
//	}
//	
//	var body: some View {
//		let summary = productsSummary
//		let sortedProducts = Array(summary.keys).sorted()
//		return ScrollView {
//			VStack(spacing: 20) {
//				Text("Produtos Solicitados")
//					.font(.title)
//					.padding()
//				
//				if !summary.isEmpty {
//					// Scroll horizontal para a tabela
//					ScrollView(.horizontal) {
//						VStack(alignment: .leading, spacing: 10) {
//							ProductsSummaryHeader()
//							
//							ForEach(sortedProducts, id: \.self) { product in
//								let totalRequested = summary[product] ?? Decimal(0)
//								let boxWeightBinding = Binding(
//									get: { boxWeights[product] ?? "" },
//									set: { boxWeights[product] = $0 }
//								)
//								
//								ProductSummaryRow(
//									product: product,
//									totalRequested: totalRequested,
//									boxWeight: boxWeightBinding
//								)
//								.padding(.vertical, 2)
//							}
//						}
//						.padding()
//						.background(Color(.systemGray6))
//						.cornerRadius(8)
//						.padding(.horizontal)
//					}
//				} else {
//					Text("Nenhum produto solicitado ainda.")
//				}
//			}
//		}
//		.navigationTitle("Produtos Solicitados")
//	}
//}
//
