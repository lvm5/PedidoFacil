//
//  OrderMessageGenerator.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-17.
//


// OrderMessageGenerator.swift

import Foundation

struct OrderMessageGenerator {
    static func generateMessage(for order: ClientOrder) -> String {
        var message = "📦 Pedido de \(order.clientName):\n\n"
        for item in order.items {
            let brand = item.product.brand ?? ""
            message += "\n - \(item.product.name) \(brand): \(String(format: "%.2f", item.quantity)) \(item.product.packageType)"
        }
        message += "\n💰 Total: R$ \(String(format: "%.2f", order.totalPrice))"
        message += "\n📈 Lucro: R$ \(String(format: "%.2f", order.totalProfit))"
        return message
    }

    static func generateReceipt(for order: ClientOrder) -> String {
        var receipt = "📦 Pedido de \(order.clientName)\n"
        receipt += "------------------------------\n"
        for item in order.items {
            let name = item.product.name
            let brand = item.product.brand ?? ""
            let quantity = String(format: "%.2f", item.quantity)
            let price = String(format: "%.2f", item.product.sellingPrice)
            let total = String(format: "%.2f", item.totalPrice)
            receipt += "- \(name) \(brand)\n  Quantidade: \(quantity) \(item.product.packageType)\n  Preço Kg/Unid: R$ \(price)\n  Total: R$ \(total)\n\n"
        }
        receipt += "------------------------------\n"
        receipt += "💰 Total a pagar: R$ \(String(format: "%.2f", order.totalPrice))\n"
        receipt += "------------------------------\n"
        receipt += "\n"
        return receipt
    }
}

