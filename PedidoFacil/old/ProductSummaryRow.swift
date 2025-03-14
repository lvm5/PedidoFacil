////
////  ProductSummaryRow.swift
////  PedidoFacil
////
////  Created by Leandro Morais on 2025-03-12.
////
//
//
//import SwiftUI
//import SwiftData
//
//import SwiftUI
//import SwiftData
//
//struct ProductSummaryRow: View {
//	var product: String
//	var totalRequested: Decimal
//	@Binding var boxWeight: String
//	@Query private var capacities: [BoxCapacity]
//	@Environment(\.modelContext) private var modelContext
//
//	// Recuperar ou criar a capacidade do produto
//	private var capacity: Decimal {
//		if let existingCapacity = capacities.first(where: { $0.productName == product }) {
//			return existingCapacity.capacity
//		} else {
//			let newCapacity = BoxCapacity(productName: product, capacity: 0)
//			modelContext.insert(newCapacity)
//			return newCapacity.capacity
//		}
//	}
//
//	// Calcula o total solicitado e evita NaN
//	private var totalRequestedDouble: Double {
//		NSDecimalNumber(decimal: totalRequested).doubleValue
//	}
//
//	// Cálculo do número de caixas e o que falta para completar a próxima
//	private var boxesAndMissing: (Int, Double) {
//		guard let capacityDouble = Double(boxWeight), capacityDouble > 0 else {
//			return (0, 0)
//		}
//
//		let boxes = Int(totalRequestedDouble / capacityDouble)
//		let remainder = totalRequestedDouble.truncatingRemainder(dividingBy: capacityDouble)
//		let missing = remainder == 0 ? 0 : capacityDouble - remainder
//
//		return (boxes, missing)
//	}
//
//	// Cor para o valor de diferença (verde = falta pouco, vermelho = valor negativo)
//	private var diffColor: Color {
//		boxesAndMissing.1 < 0 ? .red : .green
//	}
//
//	var body: some View {
//		HStack(spacing: 8) {
//			Text(product)
//				.font(.caption2)
//				.frame(width: 120, alignment: .leading)
//			Text("\(totalRequestedDouble, specifier: "%.2f")kg")
//				.font(.caption2)
//				.frame(width: 60, alignment: .center)
//			TextField("Caixa", text: $boxWeight)
//				.keyboardType(.decimalPad)
//				.textFieldStyle(.roundedBorder)
//				.frame(width: 60, alignment: .center)
//				.onChange(of: boxWeight) { newValue in
//					saveBoxWeight(newValue)
//				}
//
//			Text("\(boxesAndMissing.0)cx - \(boxesAndMissing.1, specifier: "%.2f")kg")
//				.font(.caption2)
//				.foregroundColor(diffColor)
//				.frame(width: 90, alignment: .center)
//		}
//	}
//
//	// Função para salvar o valor do peso da caixa no SwiftData
//	private func saveBoxWeight(_ newValue: String) {
//		if let existingCapacity = capacities.first(where: { $0.productName == product }) {
//			existingCapacity.capacity = Decimal(string: newValue) ?? 0
//		} else {
//			let newCapacity = BoxCapacity(productName: product, capacity: Decimal(string: newValue) ?? 0)
//			modelContext.insert(newCapacity)
//		}
//	}
//}
