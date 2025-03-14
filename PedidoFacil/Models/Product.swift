import SwiftData
import Foundation

@Model
class Product {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String
    var purchasePrice: Decimal
    var salePrice: Decimal
    var weight: String
    var stockQuantity: Decimal

    init(name: String, 
         category: String, 
         purchasePrice: Decimal, 
         salePrice: Decimal, 
         weight: String, 
         stockQuantity: Decimal) 
    {
        self.id = UUID()
        self.name = name
        self.category = category
        self.purchasePrice = purchasePrice
        self.salePrice = salePrice
        self.weight = weight
        self.stockQuantity = stockQuantity
    }

    // MARK: - Cálculo do lucro
    var profitPerUnit: Decimal {
        salePrice - purchasePrice
    }

    // MARK: - Cálculo do lucro total
    var totalProfit: Decimal {
        profitPerUnit * stockQuantity
    }
}