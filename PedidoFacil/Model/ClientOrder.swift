//
//  ClientOrder.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-16.
//

import Foundation

struct ClientOrder: Identifiable, Codable {
    let id: UUID
    var clientName: String
    var date: Date
    var items: [OrderItem]

    init(
        id: UUID = UUID(),
        clientName: String,
        date: Date,
        items: [OrderItem]
    ) {
        self.id = id
        self.clientName = clientName
        self.date = date
        self.items = items
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case clientName
        case date
        case items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        clientName = try container.decode(String.self, forKey: .clientName)
        date = try container.decode(Date.self, forKey: .date)
        items = try container.decode([OrderItem].self, forKey: .items)
    }
    
    var totalPrice: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var totalProfit: Double {
        items.reduce(0) { $0 + $1.totalProfit }
    }
}
