////
////  ContentView.swift
////  PedidoFacil
////
////  Created by Leandro Morais on 2025-03-12.
////
//
//import SwiftUI
//import SwiftData
//
//struct ContentView: View {
//	@ObservedObject var coordinator: AppCoordinator
//	@Bindable var order: Order
//	@Environment(\.modelContext) private var modelContext
//	@State private var navigateToCheckout = false
//
//	var body: some View {
//		NavigationStack {
//			VStack(spacing: 20) {
//				GroupBox("Cliente") {
//					TextField("Nome", text: $order.name)
//						.textFieldStyle(.roundedBorder)
//				}
//
//				Button("Resumo do pedido e envio") {
//					if order.hasValidItens {
//						coordinator.goToCheckout(with: order)
//					}
//				}
//				.disabled(!order.hasValidItens)
//				.frame(maxWidth: .infinity)
//				.padding()
//				.background(Color.blue)
//				.foregroundColor(.white)
//				.bold()
//				.cornerRadius(10)
//				.padding(.top, 10)
//				.padding(.horizontal)
//			}
//			.navigationTitle("Pedido")
//		}
//	}
//
//	
//	// MARK:-- Seção de informações do cliente
//	private func customerInfoSection() -> some View {
//		VStack(alignment: .leading) {
//			TextField("Nome", text: $order.name)
//				.textFieldStyle(.roundedBorder)
//		}
//	}
//	
//	// MARK:-- Seção de seleção dos produtos agrupados por categoria
//	private func productSelectionSection() -> some View {
//		// Agrupa os itens do pedido pela categoria usando o mapeamento definido
//		let groupedItems = Dictionary(grouping: order.items) { item in
//			category(for: item)
//		}
//		
//		return VStack(alignment: .leading, spacing: 15) {
//			// Itera sobre as categorias ordenadas
//			ForEach(groupedItems.keys.sorted(), id: \.self) { category in
//				// Cada categoria é exibida como uma seção
//				Section(header: Text(category).font(.headline)) {
//					ForEach(groupedItems[category] ?? []) { item in
//						productRow(for: item)
//					}
//				}
//			}
//		}
//	}
//	
//	// MARK:-- Linha de cada produto (todos os campos são editáveis)
//	private func productRow(for item: Item) -> some View {
//		VStack(alignment: .leading, spacing: 4) {
//			// Caso queira permitir a edição do nome, remova o .disabled(true)
//			TextField("Produto", text: Binding(
//				get: { item.name },
//				set: { item.name = $0 }
//			))
//			.textFieldStyle(.roundedBorder)
//			.font(.caption)
//			
//			HStack {
//				TextField("Peso/Pct.", text: Binding(
//					get: { item.weight },
//					set: { item.weight = $0 }
//				))
//				.textFieldStyle(.roundedBorder)
//				.font(.caption)
//				
//				TextField("R$ venda", value: Binding(
//					get: { item.salePricePerKg },
//					set: { item.salePricePerKg = $0 }
//				), format: .currency(code: "BRL"))
//				.keyboardType(.decimalPad)
//				.textFieldStyle(.roundedBorder)
//				.font(.caption)
//			}
//			
//			TextField("Quantidade", value: Binding(
//				get: { item.quantity },
//				set: { item.quantity = $0 }
//			), format: .number)
//			.keyboardType(.decimalPad)
//			.textFieldStyle(.roundedBorder)
//			.font(.caption)
//		}
//		.padding(.vertical, 5)
//	}
//	
//	// MARK:-- Seção do resumo do pedido
//	private func orderSummarySection() -> some View {
//		VStack(alignment: .leading, spacing: 10) {
//			let totalVenda = order.totalCost
//			HStack {
//				Text("Total:")
//					.font(.headline)
//				Spacer()
//				Text("R$ \(String(format: "%.2f", NSDecimalNumber(decimal: totalVenda).doubleValue).replacingOccurrences(of: ".", with: ","))")
//					.font(.title2)
//					.fontWeight(.bold)
//					.foregroundColor(.blue)
//			}
//		}
//	}
//	
//	// MARK:-- Dicionário de mapeamento de produtos para categorias
//	private var categoryMapping: [String: String] {
//		[
//			// Aves
//			"Coxinha": "Aves",
//			"Filé de coxa": "Aves",
//			"Meio filé peito": "Aves",
//			"Sassami": "Aves",
//			"Tulipa": "Aves",
//			// Carnes
//			"Charque": "Carnes",
//			"Contra-filé": "Carnes",
//			"Panceta": "Carnes",
//			// Frios e Embutidos
//			"Bacon em cubos": "Frios e Embutidos",
//			"Bacon fatiado": "Frios e Embutidos",
//			"Bacon manta": "Frios e Embutidos",
//			"Calabresa": "Frios e Embutidos",
//			"Linguiça": "Frios e Embutidos",
//			"Salame fatiado": "Frios e Embutidos",
//			"Salame inteiro": "Frios e Embutidos",
//			"Salsicha congelada": "Frios e Embutidos",
//			// Laticínios
//			"Manteiga": "Laticínios",
//			"Margarina": "Laticínios",
//			"Mussarela": "Laticínios",
//			"Parmesão fracionado": "Laticínios",
//			"Queijo cheddar": "Laticínios",
//			"Queijo coalho barra": "Laticínios",
//			"Queijo gorgonzola": "Laticínios",
//			"Queijo parmesão": "Laticínios",
//			"Queijo prato": "Laticínios",
//			"Queijo provolone": "Laticínios",
//			"Requeijão": "Laticínios",
//			// Congelados
//			"Batata congelada": "Congelados"
//		]
//	}
//	
//	// Função que retorna a categoria para um item baseado no seu nome
//	private func category(for item: Item) -> String {
//		return categoryMapping[item.name] ?? "Outros"
//	}
//}
