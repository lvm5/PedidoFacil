////
////  Item.swift
////  PedidoFacil
////
////  Created by Leandro Morais on 2025-03-12.
////
//
//import SwiftData
//import Foundation
//
//@Model
//class Item {
//    var id = UUID()
//    var name: String
//    var weight: String
//    var purchasePricePerKg: Decimal
//    var salePricePerKg: Decimal
//    var quantity: Decimal
//
//    var totalPrice: Decimal {
//        salePricePerKg * quantity
//    }
//
//    init(name: String, weight: String, purchasePricePerKg: Decimal, salePricePerKg: Decimal, quantity: Decimal) {
//        self.name = name
//        self.weight = weight
//        self.purchasePricePerKg = purchasePricePerKg
//        self.salePricePerKg = salePricePerKg
//        self.quantity = quantity
//    }
//
//    // Atualiza o peso do item
//    func updateWeight(newWeight: String) {
//        self.weight = newWeight
//    }
//}
