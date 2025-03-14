import SwiftData
import Foundation

@Model
class Order {
	@Attribute(.unique) var id: UUID
	var name: String
	@Relationship(deleteRule: .cascade) var items: [Item] = []
	var finalized: Bool = false

	static let defaultItems: [Item] = [
		// Aves (ordem alfabética)
		Item(name: "Coxinha", weight: "1kg", purchasePricePerKg: Decimal(12.79), salePricePerKg: Decimal(15.29), quantity: Decimal(0)),
		Item(name: "Filé de coxa", weight: "1kg", purchasePricePerKg: Decimal(12.99), salePricePerKg: Decimal(15.99), quantity: Decimal(0)),
		Item(name: "Meio filé peito", weight: "1kg", purchasePricePerKg: Decimal(17.49), salePricePerKg: Decimal(20.99), quantity: Decimal(0)),
		Item(name: "Sassami", weight: "1kg", purchasePricePerKg: Decimal(16.99), salePricePerKg: Decimal(19.49), quantity: Decimal(0)),
		Item(name: "Tulipa", weight: "1kg", purchasePricePerKg: Decimal(14.99), salePricePerKg: Decimal(18.99), quantity: Decimal(0)),

		// Carnes
		Item(name: "Charque", weight: "1kg", purchasePricePerKg: Decimal(39.99), salePricePerKg: Decimal(45.99), quantity: Decimal(0)),
		Item(name: "Contra-filé", weight: "1kg", purchasePricePerKg: Decimal(45.99), salePricePerKg: Decimal(52.99), quantity: Decimal(0)),
		Item(name: "Panceta", weight: "1kg", purchasePricePerKg: Decimal(23.99), salePricePerKg: Decimal(45.99), quantity: Decimal(0)),

		// Frios e Embutidos
		Item(name: "Bacon em cubos", weight: "1kg", purchasePricePerKg: Decimal(32.99), salePricePerKg: Decimal(38.49), quantity: Decimal(0)),
		Item(name: "Bacon fatiado", weight: "1kg", purchasePricePerKg: Decimal(33.99), salePricePerKg: Decimal(39.49), quantity: Decimal(0)),
		Item(name: "Bacon manta", weight: "1kg", purchasePricePerKg: Decimal(30.99), salePricePerKg: Decimal(36.49), quantity: Decimal(0)),
		Item(name: "Calabresa", weight: "1kg", purchasePricePerKg: Decimal(19.99), salePricePerKg: Decimal(23.49), quantity: Decimal(0)),
		Item(name: "Linguiça", weight: "1kg", purchasePricePerKg: Decimal(27.99), salePricePerKg: Decimal(33.99), quantity: Decimal(0)),
		Item(name: "Salame fatiado", weight: "1kg", purchasePricePerKg: Decimal(26.99), salePricePerKg: Decimal(32.99), quantity: Decimal(0)),
		Item(name: "Salame inteiro", weight: "1kg", purchasePricePerKg: Decimal(25.99), salePricePerKg: Decimal(31.99), quantity: Decimal(0)),
		Item(name: "Salsicha congelada", weight: "1kg", purchasePricePerKg: Decimal(10.99), salePricePerKg: Decimal(13.49), quantity: Decimal(0)),

		// Laticínios
		Item(name: "Manteiga", weight: "1kg", purchasePricePerKg: Decimal(20.99), salePricePerKg: Decimal(24.99), quantity: Decimal(0)),
		Item(name: "Margarina", weight: "1kg", purchasePricePerKg: Decimal(19.99), salePricePerKg: Decimal(23.99), quantity: Decimal(0)),
		Item(name: "Mussarela", weight: "1kg", purchasePricePerKg: Decimal(35.49), salePricePerKg: Decimal(41.49), quantity: Decimal(0)),
		Item(name: "Parmesão fracionado", weight: "1kg", purchasePricePerKg: Decimal(41.99), salePricePerKg: Decimal(48.99), quantity: Decimal(0)),
		Item(name: "Queijo cheddar", weight: "1kg", purchasePricePerKg: Decimal(39.99), salePricePerKg: Decimal(45.99), quantity: Decimal(0)),
		Item(name: "Queijo coalho barra", weight: "1kg", purchasePricePerKg: Decimal(36.99), salePricePerKg: Decimal(42.99), quantity: Decimal(0)),
		Item(name: "Queijo gorgonzola", weight: "1kg", purchasePricePerKg: Decimal(42.99), salePricePerKg: Decimal(49.99), quantity: Decimal(0)),
		Item(name: "Queijo parmesão", weight: "1kg", purchasePricePerKg: Decimal(40.99), salePricePerKg: Decimal(47.99), quantity: Decimal(0)),
		Item(name: "Queijo prato", weight: "1kg", purchasePricePerKg: Decimal(37.99), salePricePerKg: Decimal(44.99), quantity: Decimal(0)),
		Item(name: "Queijo provolone", weight: "1kg", purchasePricePerKg: Decimal(38.99), salePricePerKg: Decimal(45.99), quantity: Decimal(0)),
		Item(name: "Requeijão", weight: "1kg", purchasePricePerKg: Decimal(34.99), salePricePerKg: Decimal(39.99), quantity: Decimal(0)),

		// Congelados
		Item(name: "Batata congelada", weight: "2kg", purchasePricePerKg: Decimal(11.99), salePricePerKg: Decimal(14.49), quantity: Decimal(0))
	]

	var hasValidItens: Bool {
		!name.isEmpty && items.contains { $0.quantity > 0 }
	}

	var totalCost: Decimal {
		items.reduce(0) { $0 + $1.totalPrice }
	}

	init(name: String = "") {
		self.id = UUID()
		self.name = name
		// Aqui criamos cópia dos itens para que cada pedido tenha suas próprias instâncias
		self.items = Order.defaultItems.map { item in
			Item(name: item.name,
				 weight: item.weight,
				 purchasePricePerKg: item.purchasePricePerKg,
				 salePricePerKg: item.salePricePerKg,
				 quantity: item.quantity)
		}
	}
}

@Model
class Item {
	var id = UUID()
	var name: String
	var weight: String
	var purchasePricePerKg: Decimal
	var salePricePerKg: Decimal
	var quantity: Decimal

	var totalPrice: Decimal {
		salePricePerKg * quantity
	}

	init(name: String, weight: String, purchasePricePerKg: Decimal, salePricePerKg: Decimal, quantity: Decimal) {
		self.name = name
		self.weight = weight
		self.purchasePricePerKg = purchasePricePerKg
		self.salePricePerKg = salePricePerKg
		self.quantity = quantity
	}

	func updateWeight(newWeight: String) {
		self.weight = newWeight
	}
}
