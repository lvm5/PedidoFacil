//
//  Product.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-15.
//

import Foundation

struct Product: Identifiable {
    let id = UUID()
    var name: String
    var purchasePrice: Double
    var sellingPrice: Double
    var packageType: String
    var unitsPerPackage: Int
    var category: String
}

let sampleProducts: [Product] = [
    Product(name: "Coxinha", purchasePrice: 12.79, sellingPrice: 15.29, packageType: "Kg", unitsPerPackage: 1, category: "Aves"),
    Product(name: "Filé de coxa", purchasePrice: 12.99, sellingPrice: 15.99, packageType: "Kg", unitsPerPackage: 1, category: "Aves"),
    Product(name: "Meio filé peito", purchasePrice: 17.49, sellingPrice: 20.99, packageType: "Kg", unitsPerPackage: 1, category: "Aves"),
    Product(name: "Sassami", purchasePrice: 16.99, sellingPrice: 19.49, packageType: "Kg", unitsPerPackage: 1, category: "Aves"),
    Product(name: "Tulipa", purchasePrice: 14.99, sellingPrice: 18.99, packageType: "Kg", unitsPerPackage: 1, category: "Aves"),
    Product(name: "Charque", purchasePrice: 39.99, sellingPrice: 45.99, packageType: "Kg", unitsPerPackage: 1, category: "Carnes"),
    Product(name: "Contra-filé", purchasePrice: 45.99, sellingPrice: 52.99, packageType: "Kg", unitsPerPackage: 1, category: "Carnes"),
    Product(name: "Panceta", purchasePrice: 23.99, sellingPrice: 45.99, packageType: "Kg", unitsPerPackage: 1, category: "Carnes"),
    Product(name: "Bacon em cubos", purchasePrice: 32.99, sellingPrice: 38.49, packageType: "Kg", unitsPerPackage: 1, category: "Frios e Embutidos"),
    Product(name: "Bacon fatiado", purchasePrice: 33.99, sellingPrice: 39.49, packageType: "Kg", unitsPerPackage: 1, category: "Frios e Embutidos"),
    Product(name: "Bacon manta", purchasePrice: 30.99, sellingPrice: 36.49, packageType: "Kg", unitsPerPackage: 1, category: "Frios e Embutidos"),
    Product(name: "Calabresa", purchasePrice: 19.99, sellingPrice: 23.49, packageType: "Kg", unitsPerPackage: 1, category: "Frios e Embutidos"),
    Product(name: "Linguiça", purchasePrice: 27.99, sellingPrice: 33.99, packageType: "Kg", unitsPerPackage: 1, category: "Frios e Embutidos"),
    Product(name: "Salame fatiado", purchasePrice: 26.99, sellingPrice: 32.99, packageType: "Kg", unitsPerPackage: 1, category: "Frios e Embutidos"),
    Product(name: "Salame inteiro", purchasePrice: 25.99, sellingPrice: 31.99, packageType: "Kg", unitsPerPackage: 1, category: "Frios e Embutidos"),
    Product(name: "Salsicha congelada", purchasePrice: 10.99, sellingPrice: 13.49, packageType: "Kg", unitsPerPackage: 1, category: "Frios e Embutidos"),
    Product(name: "Manteiga", purchasePrice: 20.99, sellingPrice: 24.99, packageType: "Kg", unitsPerPackage: 1, category: "Laticínios"),
    Product(name: "Margarina", purchasePrice: 19.99, sellingPrice: 23.99, packageType: "Kg", unitsPerPackage: 1, category: "Laticínios"),
    Product(name: "Mussarela", purchasePrice: 35.49, sellingPrice: 41.49, packageType: "Kg", unitsPerPackage: 1, category: "Laticínios"),
    Product(name: "Parmesão fracionado", purchasePrice: 41.99, sellingPrice: 48.99, packageType: "Kg", unitsPerPackage: 1, category: "Laticínios"),
    Product(name: "Queijo cheddar", purchasePrice: 39.99, sellingPrice: 45.99, packageType: "Kg", unitsPerPackage: 1, category: "Laticínios"),
    Product(name: "Queijo coalho barra", purchasePrice: 36.99, sellingPrice: 42.99, packageType: "Kg", unitsPerPackage: 1, category: "Laticínios"),
    Product(name: "Queijo gorgonzola", purchasePrice: 42.99, sellingPrice: 49.99, packageType: "Kg", unitsPerPackage: 1, category: "Laticínios"),
    Product(name: "Queijo parmesão", purchasePrice: 40.99, sellingPrice: 47.99, packageType: "Kg", unitsPerPackage: 1, category: "Laticínios"),
    Product(name: "Queijo prato", purchasePrice: 37.99, sellingPrice: 44.99, packageType: "Kg", unitsPerPackage: 1, category: "Laticínios"),
    Product(name: "Queijo provolone", purchasePrice: 38.99, sellingPrice: 45.99, packageType: "Kg", unitsPerPackage: 1, category: "Laticínios"),
    Product(name: "Requeijão", purchasePrice: 34.99, sellingPrice: 39.99, packageType: "Kg", unitsPerPackage: 1, category: "Laticínios"),
    Product(name: "Batata congelada", purchasePrice: 11.99, sellingPrice: 14.49, packageType: "Kg", unitsPerPackage: 2, category: "Congelados")
]
