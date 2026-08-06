//
//  ProductModel.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-18.
//

import Foundation
import OSLog

struct ProductPublicationSummary: Equatable {
    let created: Int
    let updated: Int
}

enum ProductPublicationError: LocalizedError {
    case noValidItems

    var errorDescription: String? {
        "A lista não contém produtos válidos para publicação."
    }
}

@MainActor
class ProductModel: ObservableObject {
    @Published var products: [Product] = []
    @Published private(set) var persistenceErrorMessage: String?

    private let store: JSONFileStore<[Product]>
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "PedidoFacil",
        category: "ProductPersistence"
    )

    init(
        store: JSONFileStore<[Product]>? = nil,
        loadSamplesWhenEmpty: Bool = true
    ) {
        self.store = store ?? JSONFileStore(fileURL: Self.defaultProductsFileURL)
        loadProductsFromDisk()
        // Se não há produtos salvos, carrega produtos de exemplo
        if products.isEmpty, loadSamplesWhenEmpty {
            loadSampleProducts()
        }
    }

    // Funções para editar, adicionar e remover produtos
    func add(_ product: Product) {
        var nextProducts = products
        nextProducts.append(product)
        save(nextProducts)
    }

    func update(_ product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            var nextProducts = products
            nextProducts[index] = product
            save(nextProducts)
        }
    }

    func delete(_ product: Product) {
        save(products.filter { $0.id != product.id })
    }

    func publish(_ list: DailyPriceList) throws -> ProductPublicationSummary {
        var nextProducts = products
        var created = 0
        var updated = 0

        for item in list.items where !item.needsReview {
            guard let decimalPrice = item.price else { continue }
            let price = NSDecimalNumber(decimal: decimalPrice).doubleValue
            let packageType = Self.packageType(from: item.unit)
            let key = Self.catalogKey(name: item.name, brand: item.brand, packageSize: item.unit)

            if let index = nextProducts.firstIndex(where: {
                Self.catalogKey(name: $0.name, brand: $0.brand, packageSize: $0.packageSize) == key
            }) {
                nextProducts[index].sellingPrice = price
                if nextProducts[index].purchasePriceIsProvisional == true {
                    nextProducts[index].purchasePrice = price
                }
                if let category = item.category, !category.isEmpty {
                    nextProducts[index].category = category
                }
                updated += 1
            } else {
                nextProducts.append(
                    Product(
                        name: item.name,
                        purchasePrice: price,
                        sellingPrice: price,
                        packageType: packageType,
                        packageSize: item.unit ?? "",
                        unitsPerPackage: 1,
                        category: item.category ?? "Sem categoria",
                        brand: item.brand,
                        purchasePriceIsProvisional: true
                    )
                )
                created += 1
            }
        }

        guard created + updated > 0 else { throw ProductPublicationError.noValidItems }
        try store.save(nextProducts)
        products = nextProducts
        logger.info("Price list published. Created: \(created, privacy: .public), updated: \(updated, privacy: .public)")
        return ProductPublicationSummary(created: created, updated: updated)
    }
    
    // MARK: - Persistência JSON compatível com versões publicadas
    private static var defaultProductsFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("products.json")
    }

    private func save(_ nextProducts: [Product]) {
        do {
            try store.save(nextProducts)
            products = nextProducts
            persistenceErrorMessage = nil
            logger.info("Products saved. Count: \(self.products.count, privacy: .public)")
        } catch {
            persistenceErrorMessage = "Não foi possível salvar os produtos. Tente novamente."
            logger.error("Failed to save products: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func loadProductsFromDisk() {
        do {
            guard let result = try store.load() else {
                logger.info("No persisted products found.")
                return
            }
            products = result.value
            logger.info(
                "Products loaded. Count: \(self.products.count, privacy: .public), legacy: \(result.source.isLegacy, privacy: .public)"
            )
            if result.source.recoveredFromBackup {
                logger.error("Products recovered from backup.")
            }
        } catch {
            logger.error("Failed to load products: \(error.localizedDescription, privacy: .public)")
        }
    }

    private static func catalogKey(name: String, brand: String?, packageSize: String?) -> String {
        [name, brand ?? "", packageSize ?? ""]
            .joined(separator: "|")
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .lowercased()
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func packageType(from unit: String?) -> String {
        let normalized = unit?.lowercased() ?? ""
        if normalized.contains("kg") || normalized.hasSuffix("g") {
            return "Kg"
        }
        if normalized.contains("cx") { return "Caixa" }
        if normalized.contains("pct") { return "Pacote" }
        return "Unidade"
    }
    
    private func loadSampleProducts() {
        products = [
            // Aves
            Product(name: "Coxinha", purchasePrice: 12.79, sellingPrice: 15.29, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Aves", brand: nil),
            Product(name: "Filé de coxa", purchasePrice: 11.99, sellingPrice: 15.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Aves", brand: nil),
            Product(name: "Meio filé peito", purchasePrice: 16.49, sellingPrice: 20.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Aves", brand: nil),
            Product(name: "Meio filé peito", purchasePrice: 17.49, sellingPrice: 21.99, packageType: "Kg", packageSize: "2kg", unitsPerPackage: 6, category: "Aves", brand: "Seara"),
            Product(name: "Sassami", purchasePrice: 16.99, sellingPrice: 19.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Aves", brand: nil),
            Product(name: "Tulipa", purchasePrice: 17.99, sellingPrice: 21.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Aves", brand: nil),
            
            // Carnes
            Product(name: "Charque", purchasePrice: 39.99, sellingPrice: 45.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Carnes", brand: nil),
            Product(name: "Contra-filé", purchasePrice: 45.99, sellingPrice: 52.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Carnes", brand: nil),
            Product(name: "Panceta", purchasePrice: 23.99, sellingPrice: 27.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Carnes", brand: nil),
            
            // Frios e Embutidos
            Product(name: "Bacon em cubos", purchasePrice: 24.99, sellingPrice: 29.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Friella"),
            Product(name: "Calabresa", purchasePrice: 19.99, sellingPrice: 23.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Perdigão/Seara"),
            Product(name: "Linguiça", purchasePrice: 15.49, sellingPrice: 19.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios e Embutidos", brand: "Aurora"),
            
            // Laticínios
            Product(name: "Mussarela", purchasePrice: 35.49, sellingPrice: 41.49, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Laticínios", brand: "Lactopar"),
            Product(name: "Queijo parmesão", purchasePrice: 45.99, sellingPrice: 52.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Laticínios", brand: "Oriente"),
            Product(name: "Queijo coalho espeto", purchasePrice: 42.99, sellingPrice: 48.99, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Laticínios", brand: "Lactopar"),
            Product(name: "Requeijão", purchasePrice: 34.99, sellingPrice: 41.99, packageType: "Bisnaga", packageSize: "1.8kg", unitsPerPackage: 1, category: "Laticínios", brand: "C/Amido")
        ]
        save(products)
    }
}
