//
//  ProductModel.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-18.
//


import Foundation

@MainActor
class ProductModel: ObservableObject {
    @Published var products: [Product] = sampleProducts

    // Funções para editar, adicionar e remover produtos
    func add(_ product: Product) {
        products.append(product)
    }

    func update(_ product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index] = product
        }
    }

    func delete(_ product: Product) {
        products.removeAll { $0.id == product.id }
    }
}