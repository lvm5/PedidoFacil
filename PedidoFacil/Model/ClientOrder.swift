//
//  ClientOrder.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-16.
//

import Foundation

struct ClientOrder: Identifiable, Codable {
    let id = UUID()
    var clientName: String
    var date: Date
    var items: [OrderItem]

    
    
    var totalPrice: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var totalProfit: Double {
        items.reduce(0) { $0 + $1.totalProfit }
    }
}
