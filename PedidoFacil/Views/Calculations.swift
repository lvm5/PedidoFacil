//
//  Calculations.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-03-12.
//

import Foundation
import SwiftData

class Calculations {
	// Função para calcular quantidade de caixas e quanto falta para a próxima
	static func calculateBoxesAndMissing(total: Decimal, capacity: Decimal) -> (boxes: Int, missing: Decimal) {
		guard capacity > 0 else { return (0, 0) }

		let totalDouble = NSDecimalNumber(decimal: total).doubleValue
		let capacityDouble = NSDecimalNumber(decimal: capacity).doubleValue

		let fullBoxes = Int(totalDouble / capacityDouble)
		let remainder = totalDouble.truncatingRemainder(dividingBy: capacityDouble)
		let missing = remainder == 0 ? 0 : Decimal(capacityDouble - remainder)

		return (fullBoxes, missing)
	}
	
	// Função para calcular o total da nota fiscal (somar o valor de todos os pedidos)
	static func calculateInvoiceValue(orders: [Order]) -> Decimal {
		orders.reduce(0) { total, order in
			total + order.calculatedTotal
		}
	}
	
	// Função para calcular o valor total recebido (baseado nos toggles de pagamento)
	static func calculateTotalReceived(orders: [Order], paidOrders: [String: Bool]) -> Decimal {
		orders.reduce(0) { total, order in
			if paidOrders[order.id.uuidString] ?? false {
				return total + order.calculatedTotal
			}
			return total
		}
	}
	
	// Função para calcular a diferença (valor da nota fiscal - valor recebido)
	static func calculateDifference(orders: [Order], paidOrders: [String: Bool]) -> Decimal {
		calculateInvoiceValue(orders: orders) - calculateTotalReceived(orders: orders, paidOrders: paidOrders)
	}
	
	// Função para formatar valores como moeda
	static func formattedValue(_ value: Decimal) -> String {
		String(format: "R$ %.2f", NSDecimalNumber(decimal: value).doubleValue)
	}

	// Função para calcular o confronto de estoque x solicitado
	static func calculateStockComparison(products: [Product], orders: [Order]) -> [String: (stock: Decimal, requested: Decimal, difference: Decimal)] {
		var productDemand: [String: Decimal] = [:]

		for order in orders {
			for item in order.items {
				productDemand[item.productName, default: 0] += item.quantity
			}
		}

		var result: [String: (stock: Decimal, requested: Decimal, difference: Decimal)] = [:]

		for product in products {
			let totalRequested = productDemand[product.name] ?? 0
			if totalRequested > 0 {
				let difference = product.stockQuantity - totalRequested
				result[product.name] = (product.stockQuantity, totalRequested, difference)
			}
		}

		return result
	}

	// Função para calcular o lucro total com base nos pedidos e produtos
	static func calculateTotalProfit(products: [Product], orders: [Order]) -> Decimal {
		var totalProfit: Decimal = 0

		for order in orders {
			for item in order.items {
				if let product = products.first(where: { $0.name == item.productName }) {
					let profitPerItem = (product.salePrice - product.purchasePrice) * item.quantity
					totalProfit += profitPerItem
				}
			}
		}

		return totalProfit
	}

	// Função para formatar o lucro como moeda
	static func formattedProfitValue(_ value: Decimal) -> String {
		String(format: "R$ %.2f", NSDecimalNumber(decimal: value).doubleValue)
	}
}
