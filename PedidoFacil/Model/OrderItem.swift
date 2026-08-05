//
//  OrderItem.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-16.
//


import Foundation

struct OrderItem: Identifiable, Codable, Equatable {
    let id: UUID
    var product: Product
    var quantity: Double

    init(id: UUID = UUID(), product: Product, quantity: Double) {
        self.id = id
        self.product = product
        self.quantity = quantity
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case product
        case quantity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        product = try container.decode(Product.self, forKey: .product)
        quantity = try container.decode(Double.self, forKey: .quantity)
    }

    var totalPrice: Double {
        quantity * product.sellingPrice
    }
    var totalProfit: Double {
        quantity * (product.sellingPrice - product.purchasePrice)
    }
}
