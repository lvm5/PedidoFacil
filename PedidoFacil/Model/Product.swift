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

let sampleProducts: [Product] = [
    // Aves
    Product(name: "Coxinha", purchasePrice: 12.79, sellingPrice: 15.29, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Aves", brand: nil),
    Product(name: "Filé de coxa", purchasePrice: 11.99, sellingPrice: 15.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Aves", brand: nil),
    Product(name: "Meio filé peito", purchasePrice: 16.49, sellingPrice: 20.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Aves", brand: nil),
    Product(name: "Meio filé peito", purchasePrice: 17.49, sellingPrice: 21.99, packageType: "Kg", packageSize: "2kg", unitsPerPackage: 6, category: "Aves", brand: "Seara"),
    Product(name: "Sassami", purchasePrice: 16.99, sellingPrice: 19.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Aves", brand: nil),
    Product(name: "Sassami", purchasePrice: 17.49, sellingPrice: 20.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Aves", brand: "Individual"),
    Product(name: "Tulipa", purchasePrice: 17.99, sellingPrice: 21.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Aves", brand: nil),
    Product(name: "Tulipa", purchasePrice: 18.99, sellingPrice: 22.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Aves", brand: "Individual"),
    
    // Carnes
    Product(name: "Charque", purchasePrice: 39.99, sellingPrice: 45.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Carnes", brand: nil),
    Product(name: "Contra-filé", purchasePrice: 45.99, sellingPrice: 52.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Carnes", brand: nil),
    Product(name: "Panceta", purchasePrice: 23.99, sellingPrice: 27.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Carnes", brand: nil),
    
    // Frios e Embutidos
    Product(name: "Bacon em cubos", purchasePrice: 24.99, sellingPrice: 29.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Friella"),
    Product(name: "Bacon em cubos", purchasePrice: 25.99, sellingPrice: 30.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Friella"),
    Product(name: "Bacon fatiado", purchasePrice: 27.99, sellingPrice: 32.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Sabor Mineiro"),
    Product(name: "Bacon fatiado", purchasePrice: 29.99, sellingPrice: 34.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Besser"),
    Product(name: "Bacon fatiado", purchasePrice: 39.49, sellingPrice: 44.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Frimesa"),
    Product(name: "Bacon manta", purchasePrice: 29.99, sellingPrice: 34.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Seara Pedaços"),
    Product(name: "Bacon manta", purchasePrice: 30.99, sellingPrice: 35.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Sadia"),
    Product(name: "Bacon manta", purchasePrice: 31.49, sellingPrice: 36.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Seara"),
    Product(name: "Bacon papada", purchasePrice: 22.49, sellingPrice: 27.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Frimesa"),
    Product(name: "Calabresa", purchasePrice: 19.99, sellingPrice: 23.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Perdigão/Seara"),
    Product(name: "Calabresa", purchasePrice: 20.49, sellingPrice: 24.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Sadia/Aurora"),
    Product(name: "Linguiça", purchasePrice: 15.49, sellingPrice: 19.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Aurora"),
    Product(name: "Linguiça", purchasePrice: 19.49, sellingPrice: 23.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Nabrasa"),
    Product(name: "Salame fatiado", purchasePrice: 11.49, sellingPrice: 15.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: nil),
    Product(name: "Salame inteiro", purchasePrice: 79.99, sellingPrice: 89.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Seara/Sulita"),
    Product(name: "Salsicha congelada", purchasePrice: 8.99, sellingPrice: 12.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Seara"),
    Product(name: "Salsicha congelada", purchasePrice: 10.99, sellingPrice: 13.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Perdigão"),
    
    // Laticínios
    Product(name: "Manteiga", purchasePrice: 9.49, sellingPrice: 12.49, packageType: "Unidade", packageSize: "200g", unitsPerPackage: 1, category: "Laticínios", brand: "São Leopoldo"),
    Product(name: "Manteiga", purchasePrice: 39.99, sellingPrice: 44.99, packageType: "Bloco", packageSize: "5kg", unitsPerPackage: 1, category: "Laticínios", brand: "São Leopoldo"),
    Product(name: "Margarina", purchasePrice: 4.39, sellingPrice: 6.39, packageType: "Unidade", packageSize: "250g", unitsPerPackage: 1, category: "Laticínios", brand: "Doriana"),
    Product(name: "Margarina", purchasePrice: 4.99, sellingPrice: 6.99, packageType: "Unidade", packageSize: "250g", unitsPerPackage: 1, category: "Laticínios", brand: "Qualy"),
    Product(name: "Margarina", purchasePrice: 5.99, sellingPrice: 8.99, packageType: "Unidade", packageSize: "500g", unitsPerPackage: 1, category: "Laticínios", brand: "Doriana"),
    Product(name: "Margarina", purchasePrice: 6.99, sellingPrice: 9.99, packageType: "Unidade", packageSize: "500g", unitsPerPackage: 1, category: "Laticínios", brand: "Becel"),
    Product(name: "Margarina", purchasePrice: 7.49, sellingPrice: 10.49, packageType: "Unidade", packageSize: "500g", unitsPerPackage: 1, category: "Laticínios", brand: "Qualy"),
    Product(name: "Mussarela", purchasePrice: 35.49, sellingPrice: 41.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Laticínios", brand: "Lactopar/Cristaulat/Frizzo/Lira"),
    Product(name: "Mussarela", purchasePrice: 36.49, sellingPrice: 42.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Laticínios", brand: "Dneve"),
    Product(name: "Mussarela", purchasePrice: 36.99, sellingPrice: 42.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Laticínios", brand: "São Leopoldo"),
    Product(name: "Parmesão fracionado", purchasePrice: 73.99, sellingPrice: 83.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Laticínios", brand: "São Leopoldo"),
    Product(name: "Queijo cheddar", purchasePrice: 50.99, sellingPrice: 58.99, packageType: "Unidade", packageSize: "1.5kg", unitsPerPackage: 1, category: "Laticínios", brand: "Scala"),
    Product(name: "Queijo coalho barra", purchasePrice: 42.99, sellingPrice: 48.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Laticínios", brand: nil),
    Product(name: "Queijo coalho espeto", purchasePrice: 42.99, sellingPrice: 48.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Laticínios", brand: "Lactopar/Lira"),
    Product(name: "Queijo coalho espeto", purchasePrice: 47.99, sellingPrice: 53.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Laticínios", brand: "São Leopoldo"),
    Product(name: "Queijo gorgonzola", purchasePrice: 54.99, sellingPrice: 62.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Laticínios", brand: "Grand Mestri"),
    Product(name: "Queijo parmesão", purchasePrice: 45.99, sellingPrice: 52.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Laticínios", brand: "Oriente"),
    Product(name: "Queijo prato", purchasePrice: 37.99, sellingPrice: 44.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Laticínios", brand: "Lactopar"),
    Product(name: "Queijo provolone", purchasePrice: 42.49, sellingPrice: 48.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Laticínios", brand: "Lactopar/Opa"),
    Product(name: "Queijo provolone", purchasePrice: 54.99, sellingPrice: 62.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Laticínios", brand: "São Leopoldo"),
    Product(name: "Requeijão", purchasePrice: 34.99, sellingPrice: 41.99, packageType: "Bisnaga", packageSize: "1.8kg", unitsPerPackage: 1, category: "Laticínios", brand: "C/Amido"),
    Product(name: "Requeijão", purchasePrice: 45.49, sellingPrice: 52.49, packageType: "Unidade", packageSize: "1.5kg", unitsPerPackage: 1, category: "Laticínios", brand: "Scala"),
    Product(name: "Requeijão", purchasePrice: 49.99, sellingPrice: 56.99, packageType: "Bisnaga", packageSize: "1.8kg", unitsPerPackage: 1, category: "Laticínios", brand: "S/Amido"),
    Product(name: "Requeijão copo", purchasePrice: 8.49, sellingPrice: 11.49, packageType: "Copo", packageSize: "250g", unitsPerPackage: 1, category: "Laticínios", brand: "São Leopoldo"),
    Product(name: "Requeijão copo", purchasePrice: 11.99, sellingPrice: 14.99, packageType: "Copo", packageSize: "250g", unitsPerPackage: 1, category: "Laticínios", brand: "Crioulo"),
    
    // Congelados
    Product(name: "Batata congelada", purchasePrice: 11.99, sellingPrice: 14.49, packageType: "Kg", packageSize: "2kg", unitsPerPackage: 2, category: "Congelados", brand: "Bem Brasil"),
    Product(name: "Batata congelada", purchasePrice: 14.99, sellingPrice: 17.99, packageType: "Kg", packageSize: "2kg", unitsPerPackage: 2, category: "Congelados", brand: "McCain")
]

