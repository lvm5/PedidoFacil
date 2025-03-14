////
////  MainView.swift
////  PedidoFacil
////
////  Created by Leandro Morais on 2025-03-12.
////
//
//import SwiftUI
//import SwiftData
//
//struct MainView: View {
//	@ObservedObject var coordinator: AppCoordinator
//	@Query private var orders: [Order]
//	@Query private var capacities: [BoxCapacity]
//	@Environment(\.modelContext) private var modelContext
//
//	// Calcula o total solicitado para cada produto
//	var productsSummary: [String: Decimal] {
//		var summary = [String: Decimal]()
//		for order in orders {
//			for item in order.items where item.quantity > 0 {
//				summary[item.name, default: 0] += item.quantity
//			}
//		}
//		return summary
//	}
//
//	var body: some View {
//		NavigationStack {
//			ScrollView {
//				VStack(spacing: 20) {
//					Text("Bem-vindo ao PedidoFacil")
//						.font(.title)
//						.padding()
//
//					if !productsSummary.isEmpty {
//						ScrollView(.horizontal) {
//							VStack(alignment: .leading, spacing: 10) {
//								ProductsSummaryHeader()
//								
//								ForEach(productsSummary.keys.sorted(), id: \.self) { product in
//									ProductSummaryRow(
//										product: product,
//										totalRequested: productsSummary[product] ?? Decimal(0),
//										boxWeight: .constant(""),
//										capacities: capacities,
//										modelContext: modelContext
//									)
//									.padding(.vertical, 2)
//								}
//							}
//							.padding()
//							.background(Color(.systemGray6))
//							.cornerRadius(8)
//							.padding(.horizontal)
//						}
//					} else {
//						Text("Nenhum produto solicitado ainda.")
//					}
//				}
//			}
//			.navigationTitle("PedidoFacil")
//			.toolbar {
//				ToolbarItemGroup(placement: .bottomBar) {
//					Button("Home") { coordinator.goToMain() }
//					Spacer()
//					Button("Pedidos Realizados") { coordinator.goToOrderList() }
//					Spacer()
//					Button("Novo Pedido") { coordinator.goToNewOrder() }
//				}
//			}
//		}
//	}
//}
//
//struct ProductsSummaryHeader: View {
//	var body: some View {
//		HStack(spacing: 8) {
//			Text("Produto")
//				.font(.caption2)
//				.frame(width: 120, alignment: .leading)
//			Text("Total Solicitado")
//				.font(.caption2)
//				.frame(width: 120, alignment: .center)
//			Text("Peso Caixa")
//				.font(.caption2)
//				.frame(width: 80, alignment: .center)
//			Text("Cx/Falta")
//				.font(.caption2)
//				.frame(width: 70, alignment: .center)
//		}
//	}
//}
