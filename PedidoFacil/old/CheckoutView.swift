////
////  CheckoutView.swift
////  PedidoFacil
////
////  Created by Leandro Morais on 2025-03-12.
////
//
//
//import SwiftUI
//import SwiftData
//
//struct CheckoutView: View {
//	// MARK:-- Propriedades da View
//	var order: Order // MARK:-- Objeto de pedido recebido
//	@Environment(\.modelContext) private var modelContext // MARK:-- Contexto para acesso ao SwiftData (https://developer.apple.com/documentation/swiftui/modelcontext)
//	@Environment(\.dismiss) private var dismiss // MARK:-- Função para fechar a View
//
//	var body: some View {
//		ScrollView {
//			VStack(spacing: 20) {
//				GroupBox("Resumo do Pedido") {
///				VStack(alignment: .leading, spacing: 15) {
//						// MARK:-- Loop para exibir os itens do pedido
//						ForEach(order.items.filter { $0.quantity > 0 }, id: \.id) { item in
//							let itemTotal = item.salePricePerKg * item.quantity
//							// Formata o preço do item em uma variável intermediária para facilitar a inferência de tipos
//							let formattedItemPrice = String(format: "%.2f", NSDecimalNumber(decimal: itemTotal).doubleValue)
//								.replacingOccurrences(of: ".", with: ",")
//							
//							HStack {
//								VStack(alignment: .leading) {
//									Text(item.name)
//										.font(.headline)
//									Text("\(item.quantity) Kg")
//										.font(.caption)
//										.foregroundColor(.secondary)
//								}
//								Spacer()
//								// MARK:-- Exibe o preço do item com formatação
//								Text("R$ \(formattedItemPrice)")
//									.font(.headline)
//									.foregroundColor(.blue)
//							}
//							.padding(.vertical, 4)
//						}
//
//						Divider()
//
//						let total = order.items.reduce(0) { $0 + $1.salePricePerKg * $1.quantity }
//						// Formata o total em uma variável intermediária
//						let formattedTotal = String(format: "%.2f", NSDecimalNumber(decimal: total).doubleValue)
//							.replacingOccurrences(of: ".", with: ",")
//						
//						HStack {
//							Text("Total da Compra:")
//								.font(.headline)
//							Spacer()
//							// MARK:-- Exibe o total com formatação
//							Text("R$ \(formattedTotal)")
//								.font(.title2)
//								.fontWeight(.bold)
//								.foregroundColor(.blue)
//						}
//					}
//					.padding()
//				}
//
//				// MARK:-- Botão para Finalizar Pedido e Salvar
//				Button("Finalizar Pedido") {
//					saveOrder() // Chama a função para salvar o pedido
//					dismiss()   // Fecha a View após salvar
//				}
//				.frame(maxWidth: .infinity)
//				.padding()
//				.background(Color.green)
//				.foregroundColor(.white)
//				.bold()
//				.cornerRadius(10)
//
//				// MARK:-- Botão de Exportação do Pedido
//				VStack(spacing: 12) {
//					ShareLink(item: exportOrderData()) {
//						HStack {
//							Image(systemName: "square.and.arrow.up")
//							Text("Exportar Pedido")
//								.fontWeight(.bold)
//						}
//						.frame(maxWidth: .infinity)
//						.padding()
//						.background(Color.blue)
//						.foregroundColor(.white)
//						.cornerRadius(10)
//					}
//				}
//				.padding(.top, 20)
//			}
//			.padding(.horizontal)
//		}
//		.navigationTitle("Finalizar Pedido")
//		.navigationBarTitleDisplayMode(.inline)
//	}
//
//	// MARK:-- Função para salvar o pedido usando SwiftData
//	private func saveOrder() {
//		// Se o pedido já estiver finalizado, não insira novamente
//		if order.finalized {
//			print("Log: Pedido já finalizado. Não vamos inserir de novo.")
//			return
//		}
//
//		let orderId = order.id
//		let predicate = #Predicate<Order> { (orderItem: Order) in
//			orderItem.id == orderId
//		}
//		let descriptor = FetchDescriptor<Order>(predicate: predicate)
//
//		if let existingOrder = try? modelContext.fetch(descriptor).first {
//			// Atualiza pedido existente
//			existingOrder.items = order.items
//			print("Log: Pedido existente atualizado.")
//		} else {
//			// Insere o novo pedido
//			modelContext.insert(order)
//			print("Log: Novo pedido inserido.")
//		}
//		order.finalized = true
//		print("Log: Pedido finalizado com sucesso.")
//	}
//
//	// MARK:-- Função para exportar os dados do pedido como String
//	private func exportOrderData() -> String {
//		let total = order.items.reduce(0) { $0 + $1.salePricePerKg * $1.quantity }
//		var orderDetails = """
//Pedido Finalizado:
//Cliente: \(order.name)
//
//Itens do Pedido:
//"""
//		// Adiciona cada item do pedido na string de exportação
//		for item in order.items.filter({ $0.quantity > 0 }) {
//			let itemTotal = item.salePricePerKg * item.quantity
//			let formattedItemPrice = String(format: "%.2f", NSDecimalNumber(decimal: itemTotal).doubleValue)
//				.replacingOccurrences(of: ".", with: ",")
//			orderDetails += "\n- \(item.name) | \(item.quantity) Kg | R$ \(formattedItemPrice)"
//		}
//		
//		let formattedTotal = String(format: "%.2f", NSDecimalNumber(decimal: total).doubleValue)
//			.replacingOccurrences(of: ".", with: ",")
//		orderDetails += "\n\nTotal da Compra: R$ \(formattedTotal)"
//		print("Log: Dados do pedido exportados.") // MARK:-- Log para depuração
//		return orderDetails
//	}
//}
