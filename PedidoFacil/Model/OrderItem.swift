//
//  OrderItem.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-16.
//


import Foundation

struct OrderItem: Identifiable, Codable {
    let id = UUID()
    var product: Product
    var quantity: Double
    var totalPrice: Double {
        quantity * product.sellingPrice
    }
    var totalProfit: Double {
        quantity * (product.sellingPrice - product.purchasePrice)
    }
}
