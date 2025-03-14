 //
//  MainView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-03-12.
//

import SwiftUI
import SwiftData

struct MainView: View {
	// MARK:-- Consulta todos os pedidos cadastrados no SwiftData
	@Query private var orders: [Order]
	
	// MARK:-- Consulta todas as capacidades de caixa no SwiftData
	@Query private var capacities: [BoxCapacity]
	
	// MARK:-- Acesso ao ModelContext para inserir/atualizar modelos
	@Environment(\.modelContext) private var modelContext
	
	// MARK:-- Calcula o total solicitado para cada produto (em kg)
	// Apenas itens com quantidade > 0 são considerados
	var productsSummary: [String: Decimal] {
		var summary = [String: Decimal]()
		for order in orders {
			for item in order.items {
				if item.quantity > 0 {
					let key = item.name
					let qty = item.quantity
					if let current = summary[key] {
						summary[key] = current + qty
					} else {
						summary[key] = qty
					}
				}
			}
		}
		return summary
	}
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 20) {
					// Mensagem de boas-vindas
					Text("Bem-vindo ao PedidoFacil")
						.font(.title)
						.padding()
					
					// Se existir algum produto solicitado, exibe a seção de resumo
					if !productsSummary.isEmpty {
						// Rolagem horizontal para a tabela
						ScrollView(.horizontal) {
							VStack(alignment: .leading, spacing: 10) {
								Text("Resumo dos Produtos Solicitados")
									.font(.headline)
								
								// Cabeçalho das colunas com fonte reduzida e larguras menores
								HStack(spacing: 8) {
									Text("Produto")
										.font(.caption2)
										.frame(width: 120, alignment: .leading)
									Text("Total")
										.font(.caption2)
										.frame(width: 60, alignment: .center)
									Text("Caixa")
										.font(.caption2)
										.frame(width: 60, alignment: .center)
									Text("Cx/Falta")
										.font(.caption2)
										.frame(width: 70, alignment: .center)
								}
								
								// Para cada produto solicitado, usa a subview para encapsular os cálculos
								ForEach(productsSummary.keys.sorted(), id: \.self) { product in
									ProductSummaryRow(
										product: product,
										totalRequested: productsSummary[product] ?? Decimal(0),
										capacities: capacities,
										modelContext: modelContext
									)
									.padding(.vertical, 2)
								}
							}
							.padding()
							.background(Color(.systemGray6))
							.cornerRadius(8)
							.padding(.horizontal)
						}
					} else {
						Text("Nenhum produto solicitado ainda.")
					}
				}
			}
			.navigationTitle("PedidoFacil")
			.toolbar {
				ToolbarItemGroup(placement: .bottomBar) {
					NavigationLink(destination: OrderListView()) {
						Label("Pedidos finalizados", systemImage: "list.bullet")
					}
					Spacer()
					NavigationLink(destination: ContentView(order: Order(name: ""))) {
						Label("Novo Pedido", systemImage: "plus.circle")
					}
					Spacer()
					NavigationLink(destination: CheckoutView(order: Order(name: ""))) {
						Label("Produtos Solicitados", systemImage: "cart")
					}
				}
			}
		}
	}
}

