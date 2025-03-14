//
//  OrderListView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-03-12.
//


import SwiftUI
import SwiftData

struct OrderListView: View {
	@Environment(\.modelContext) private var modelContext
	@Query private var orders: [Order]
	@State private var navigateToContentView: Bool = false
	@State private var tempOrder: Order? = nil

	var body: some View {
		NavigationStack {
			VStack {
				// MARK:-- Somatória dos pedidos
				HStack {
					Text("Total de Pedidos:")
						.font(.headline)
					Spacer()
					// Calcula a somatória dos totalCost de todos os pedidos
					let totalOrders = orders.reduce(Decimal(0)) { $0 + $1.totalCost }
					Text("R$ \(String(format: "%.2f", NSDecimalNumber(decimal: totalOrders).doubleValue).replacingOccurrences(of: ".", with: ","))")
						.font(.headline)
						.foregroundColor(.blue)
				}
				.padding()

				// MARK:-- Lista de Pedidos
				List {
					ForEach(orders) { order in
						NavigationLink(destination: {
							if order.finalized {
								// Se o pedido está finalizado, mostra a visualização final (CheckoutView, por exemplo)
								CheckoutView(order: order)
							} else {
								// Se o pedido não está finalizado, permite editar o pedido (ContentView)
								ContentView(order: order)
							}
						}) {
							VStack(alignment: .leading) {
								Text(order.name)
									.font(.headline)
								Text("R$ \(String(format: "%.2f", NSDecimalNumber(decimal: order.totalCost).doubleValue).replacingOccurrences(of: ".", with: ","))")
									.font(.subheadline)
									.foregroundColor(.blue)
							}
						}
					}
					.onDelete(perform: deleteOrder)
				}
			}
			.navigationTitle("Pedidos Finalizados")
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button {
						// Cria um novo pedido somente quando o usuário clica em "Novo Pedido"
						let newOrder = Order()
						modelContext.insert(newOrder)
						navigateToContentView = true
						tempOrder = newOrder
					} label: {
						Label("Novo Pedido", systemImage: "plus")
					}
				}
			}
			.navigationDestination(isPresented: $navigateToContentView) {
				if let order = tempOrder {
					// Navega para a ContentView para edição do novo pedido
					ContentView(order: order)
				}
			}
		}
	}

	private func deleteOrder(at offsets: IndexSet) {
		for index in offsets {
			let order = orders[index]
			modelContext.delete(order)
		}
	}
}
