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
	// Armazena os pesos da caixa (capacidade) para cada produto (persistidos via SwiftData neste exemplo, mas aqui usamos @State para simplicidade)
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
		ScrollView {
			VStack(spacing: 20) {
				Text("Produtos Solicitados")
					.font(.title)
					.padding()
				
				if !productsSummary.isEmpty {
					// Quebramos a tabela em uma ScrollView horizontal para evitar que estoure a largura da tela
					ScrollView(.horizontal) {
						VStack(alignment: .leading, spacing: 10) {
							// Cabeçalho da tabela
							ProductsSummaryHeader()
							
							// Usamos uma variável local para reduzir a complexidade da expressão
							let summary = productsSummary
							ForEach(summary.keys.sorted(), id: \.self) { product in
								ProductSummaryRow(
									product: product,
									totalRequested: summary[product] ?? Decimal(0),
									boxWeight: Binding(
										get: { boxWeights[product] ?? "" },
										set: { boxWeights[product] = $0 }
									)
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
		.navigationTitle("Produtos Solicitados")
	}
}

struct ProductsSummaryHeader: View {
	var body: some View {
		HStack(spacing: 8) {
			Text("Produto")
				.font(.caption2)
				.frame(width: 120, alignment: .leading)
			Text("Total Solicitado")
				.font(.caption2)
				.frame(width: 120, alignment: .center)
			Text("Peso Caixa")
				.font(.caption2)
				.frame(width: 80, alignment: .center)
			Text("Cx/Falta")
				.font(.caption2)
				.frame(width: 70, alignment: .center)
		}
	}
}

struct ProductSummaryRow: View {
	var product: String
	var totalRequested: Decimal
	var capacities: [BoxCapacity]
	var modelContext: ModelContext

	// Converte o total solicitado para Double
	var totalRequestedDouble: Double {
		NSDecimalNumber(decimal: totalRequested).doubleValue
	}
	
	// Retorna o objeto BoxCapacity para este produto. Se não existir, cria um novo.
	private var boxCapacityObj: BoxCapacity {
		if let found = capacities.first(where: { $0.productName == product }) {
			return found
		} else {
			let newCap = BoxCapacity(productName: product, capacity: 0)
			modelContext.insert(newCap)
			return newCap
		}
	}
	
	// Binding para a propriedade capacity do BoxCapacity
	private var capacityBinding: Binding<Decimal> {
		Binding<Decimal>(
			get: { boxCapacityObj.capacity },
			set: { newValue in
				boxCapacityObj.capacity = newValue
			}
		)
	}
	
	// Converte a capacidade para Double
	private var capacityDouble: Double {
		NSDecimalNumber(decimal: boxCapacityObj.capacity).doubleValue
	}
	
	// Quantidade de caixas necessárias (se total excede capacidade)
	var boxesNeeded: Int {
		guard capacityDouble > 0 else { return 0 }
		let fullBoxes = Int(totalRequestedDouble / capacityDouble)
		let remainder = totalRequestedDouble.truncatingRemainder(dividingBy: capacityDouble)
		return remainder == 0 ? fullBoxes : fullBoxes + 1
	}
	
	// Calcula quanto falta para completar a próxima caixa
	var missing: Double {
		if capacityDouble > 0 {
			let remainder = totalRequestedDouble.truncatingRemainder(dividingBy: capacityDouble)
			return remainder == 0 ? 0 : capacityDouble - remainder
		}
		return 0
	}
	
	// Define a cor: verde para valores positivos, cinza para zero, vermelho para negativos.
	var diffColor: Color {
		if missing < 0 { return .red }
		else if missing == 0 { return .gray }
		else { return .green }
	}
	
	var body: some View {
		HStack(spacing: 8) {
			Text(product)
				.font(.caption2)
				.frame(width: 120, alignment: .leading)
			Text("\(totalRequestedDouble, specifier: "%.2f")kg")
				.font(.caption2)
				.frame(width: 60, alignment: .center)
			// Campo para inserir o peso da caixa (persistido em SwiftData)
			TextField("Caixa", value: capacityBinding, format: .number)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.keyboardType(.decimalPad)
				.font(.caption2)
				.frame(width: 60, alignment: .center)
			Text("\(boxesNeeded)cx-\(missing, specifier: "%.2f")kg")
				.font(.caption2)
				.frame(width: 70, alignment: .center)
				.foregroundColor(diffColor)
		}
	}
}
