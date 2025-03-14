//
//  MainView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-03-12.
//


import SwiftUI
import SwiftData

struct MainView: View {
	// Consulta todos os pedidos cadastrados no SwiftData
	@Query private var orders: [Order]
	
	// Armazena o peso da caixa para cada produto (chave: nome do produto, valor: texto digitado)
	@State private var boxWeights: [String: String] = [:]
	
	// Calcula o total solicitado para cada produto (em kg) a partir dos pedidos
	// Apenas itens com quantidade > 0 são considerados
	
	var productsSummary: [String: Decimal] {
		var summary = [String: Decimal]()
		for order in orders {
			for item in order.items where item.quantity > 0 {
				if let current = summary[item.name] {
					summary[item.name] = current + item.quantity
				} else {
					summary[item.name] = item.quantity
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
						VStack(alignment: .leading, spacing: 10) {
							Text("Resumo dos Produtos Solicitados")
								.font(.headline)
							
							// Cabeçalho das colunas com fonte reduzida
							HStack {
								Text("Produto")
									.font(.caption2)
									.frame(width: 150, alignment: .leading)
								Text("Total Solicitado")
									.font(.caption2)
									.frame(width: 120, alignment: .center)
								Text("Peso Caixa")
									.font(.caption2)
									.frame(width: 80, alignment: .center)
								Text("Falta")
									.font(.caption2)
									.frame(width: 120, alignment: .center)
							}
							
							// Para cada produto solicitado
							ForEach(productsSummary.keys.sorted(), id: \.self) { product in
								HStack {
									Text(product)
										.font(.caption2)
										.frame(width: 150, alignment: .leading)
									
									let totalRequested = productsSummary[product] ?? 0
									let totalRequestedDouble = NSDecimalNumber(decimal: totalRequested).doubleValue
									Text("\(totalRequestedDouble, specifier: "%.2f")kg")
										.font(.caption2)
										.frame(width: 120, alignment: .center)
									
									// Campo para inserir o peso da caixa (capacidade) – valor editável
									TextField("Caixa", text: Binding(
										get: { boxWeights[product] ?? "" },
										set: { boxWeights[product] = $0 }
									))
									.textFieldStyle(RoundedBorderTextFieldStyle())
									.keyboardType(.decimalPad)
									.font(.caption2)
									.frame(width: 80, alignment: .center)
									
									// Cálculo da diferença: se a caixa tem capacidade X e o total solicitado é Y,
									// a diferença (falta para completar a caixa atual) é:
									// missing = (X - (Y mod X)), se Y mod X ≠ 0; caso contrário, 0.
									let capacity = Double(boxWeights[product] ?? "") ?? 0
									var missing: Double = 0
									if capacity > 0 {
										let remainder = totalRequestedDouble.truncatingRemainder(dividingBy: capacity)
										missing = remainder == 0 ? 0 : capacity - remainder
									}
									
									// Define a cor: se missing for negativo (caso ocorra), vermelho; se zero, cinza; se positivo, verde.
									let diffColor: Color = missing < 0 ? .red : (missing == 0 ? .gray : .green)
									Text("\(missing, specifier: "%.2f")kg")
										.font(.caption2)
										.frame(width: 120, alignment: .center)
										.foregroundColor(diffColor)
								}
								.padding(.vertical, 2)
							}
						}
						.padding()
						.background(Color(.systemGray6))
						.cornerRadius(8)
						.padding(.horizontal)
					} else {
						Text("Nenhum produto solicitado ainda.")
					}
					
					// Outros conteúdos podem ser adicionados abaixo, se necessário.
				}
			}
			.navigationTitle("PedidoFacil")
			.toolbar {
				ToolbarItemGroup(placement: .bottomBar) {
					// Navega para a lista de pedidos finalizados
					NavigationLink(destination: OrderListView()) {
						Label("Pedidos finalizados", systemImage: "list.bullet")
					}
					Spacer()
					// Navega para a tela de novo pedido
					NavigationLink(destination: ContentView(order: Order(name: ""))) {
						Label("Novo Pedido", systemImage: "plus.circle")
					}
					Spacer()
					// Navega para a view de produtos solicitados (ProductsView)
					NavigationLink(destination: RequestedProductsView()) {
						Label("Produtos Solicitados", systemImage: "cart")
					}
				}
			}
		}
	}
}



