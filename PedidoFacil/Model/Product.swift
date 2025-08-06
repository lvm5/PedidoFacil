//
//  Product.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-15.
//

import Foundation

struct Product: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var purchasePrice: Double
    var sellingPrice: Double
    var packageType: String
    var packageSize: String
    var unitsPerPackage: Int
    var category: String
    var brand: String? // Opcional para quando quiser especificar marca
    var calculatedUnits: Int? = nil
    
    init(name: String, purchasePrice: Double, sellingPrice: Double, packageType: String, packageSize: String, unitsPerPackage: Int, category: String, brand: String? = nil) {
        self.id = UUID()
        self.name = name
        self.purchasePrice = purchasePrice
        self.sellingPrice = sellingPrice
        self.packageType = packageType
        self.packageSize = packageSize
        self.unitsPerPackage = unitsPerPackage
        self.category = category
        self.brand = brand
        self.calculatedUnits = nil
    }
}

// Lista de produtos de exemplo removida - agora os produtos são gerenciados pelo ProductModel

