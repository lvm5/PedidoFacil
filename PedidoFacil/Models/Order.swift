//
//  Order.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-03-12.
//

import SwiftData
import Foundation

@Model
class Order {
    @Attribute(.unique) var id: UUID
    var customerName: String
    var customerPhone: String
    @Relationship(deleteRule: .cascade) var items: [OrderItem] = []
    var totalValue: Decimal
    var isFinalized: Bool

    init(customerName: String,
         customerPhone: String,
         items: [OrderItem] = [],
         totalValue: Decimal = 0,
         isFinalized: Bool = false) 
    {
        self.id = UUID()
        self.customerName = customerName
        self.customerPhone = customerPhone
        self.items = items
        self.totalValue = totalValue
        self.isFinalized = isFinalized
    }

    // Cálculo automático do valor total com base nos itens
    var calculatedTotal: Decimal {
        items.reduce(0) { $0 + $1.totalPrice }
    }
}