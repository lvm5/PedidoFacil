//
//  OrderItem.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-03-12.
//


//
//  OrderItem.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-03-12.
//

import SwiftData
import Foundation

@Model
class OrderItem {
    @Attribute(.unique) var id: UUID
    var productName: String
    var quantity: Decimal
    var price: Decimal

    // Cálculo automático do valor total por item
    var totalPrice: Decimal {
        quantity * price
    }

    init(productName: String, quantity: Decimal, price: Decimal) {
        self.id = UUID()
        self.productName = productName
        self.quantity = quantity
        self.price = price
    }
}