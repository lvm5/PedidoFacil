//
//  ProductModel.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-18.
//

import Foundation

@MainActor
class ProductModel: ObservableObject {
    @Published var products: [Product] = []

    init() {
        loadProductsFromDisk()
        // Se não há produtos salvos, carrega produtos de exemplo
        if products.isEmpty {
            loadSampleProducts()
        }
    }

    // Funções para editar, adicionar e remover produtos
    func add(_ product: Product) {
        products.append(product)
        saveProductsToDisk()
    }

    func update(_ product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index] = product
            saveProductsToDisk()
        }
    }

    func delete(_ product: Product) {
        products.removeAll { $0.id == product.id }
        saveProductsToDisk()
    }
    
    // MARK: - Persistência com FileManager + JSON
    private var productsFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("products.json")
    }

    private func saveProductsToDisk() {
        do {
            let data = try JSONEncoder().encode(products)
            try data.write(to: productsFileURL)
            print("✅ Produtos salvos com sucesso.")
        } catch {
            print("❌ Erro ao salvar produtos: \(error)")
        }
    }

    private func loadProductsFromDisk() {
        do {
            let data = try Data(contentsOf: productsFileURL)
            let savedProducts = try JSONDecoder().decode([Product].self, from: data)
            products = savedProducts
            print("📥 Produtos carregados com sucesso.")
        } catch {
            print("⚠️ Nenhum produto salvo encontrado ou erro ao carregar: \(error)")
        }
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
        saveProductsToDisk()
    }
}

