//
//  OrderViewModel.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-17.
//

import Foundation
import SwiftUI

@MainActor
class OrderViewModel: ObservableObject {
    @Published var quantityKg: String = ""
    @Published var totalPrice: Double = 0.0
    @Published var totalProfit: Double = 0.0
    @Published var selectedProduct: Product = Product(name: "Selecione um produto", purchasePrice: 0, sellingPrice: 0, packageType: "", packageSize: "", unitsPerPackage: 1, category: "")
    @Published var orders: [OrderItem] = []
    @Published var showingCalculation: Bool = false
    @Published var purchaseList: [Product] = []
    @Published var pendingList: [Product] = []
    @Published var clientName: String = ""
    @Published var clientOrders: [ClientOrder] = []
    @Published var showClientNameField: Bool = false
    @Published var receiptText: String = ""
    
    init() {
        loadClientOrdersFromDisk()
    }
   
    /// CALC SOLICITAR ITENS
    func calculate() {
        guard let kg = Double(quantityKg) else {
            print("Quantidade inválida")
            return
        }
        totalPrice = kg * selectedProduct.sellingPrice
        totalProfit = kg * (selectedProduct.sellingPrice - selectedProduct.purchasePrice)
        showingCalculation = true
    }
    
    /// + ORDER
    func addOrder() {
        guard let quantity = Double(quantityKg), quantity > 0 else {
            print("❌ Quantidade inválida")
            return
        }
        let newOrder = OrderItem(product: selectedProduct, quantity: quantity)
        orders.append(newOrder)
        generatePurchaseSuggestions()
        quantityKg = ""
        showingCalculation = false
        showClientNameField = true
    }
    
    /// - ORDER
    func removeOrder(_ order: OrderItem) {
        orders.removeAll { $0.id == order.id }
    }
    
    /// CLEAN ORDER
    func clearAllOrders() {
        orders.removeAll()
    }
    
    /// PURCHASE LIST (EACH ORDER)
    func generatePurchaseSuggestions() {
        var demandMap: [Product: Double] = [:]
        for order in orders {
            demandMap[order.product, default: 0.0] += order.quantity
        }
        purchaseList.removeAll()
        pendingList.removeAll()
        for (product, totalKg) in demandMap {
            let kgPerUnit = Double(product.unitsPerPackage)
            let totalPackages = totalKg / kgPerUnit
            let wholePackages = Int(totalPackages)
            if wholePackages >= 1 {
                var productCopy = product
                productCopy.calculatedUnits = wholePackages
                purchaseList.append(productCopy)
            }
            let remainderKg = totalKg.truncatingRemainder(dividingBy: kgPerUnit)
            if remainderKg > 0 {
                pendingList.append(product)
            }
        }
    }
    
    /// PURCHASE LIST (ALL ORDERS)
    func generatePurchaseSuggestionsFromAllOrders() {
        var demandMap: [Product: Double] = [:]
        
        // Percorrer todos os pedidos de todos os clientes
        for order in clientOrders {
            for item in order.items {
                demandMap[item.product, default: 0.0] += item.quantity
            }
        }
        
        purchaseList.removeAll()
        pendingList.removeAll()
        
        for (product, totalKg) in demandMap {
            let kgPerUnit = Double(product.unitsPerPackage)
            let totalPackages = totalKg / kgPerUnit
            let wholePackages = Int(totalPackages) // arredonda pra baixo
            
            if wholePackages >= 1 {
                var productCopy = product
                productCopy.calculatedUnits = wholePackages
                purchaseList.append(productCopy)
            }
            
            let remainderKg = totalKg.truncatingRemainder(dividingBy: kgPerUnit)
            if remainderKg > 0 {
                pendingList.append(product)
            }
        }
    }
    
    /// SAVE CLIENT ORDER
    func saveClientOrder() {
        // 1. Verificar se nome e pedidos são válidos
        guard !clientName.isEmpty else {
            print("Por favor, insira o nome do cliente.")
            return
        }
        guard !orders.isEmpty else {
            print("O pedido está vazio.")
            return
        }
        
        // 2. Criar novo pedido do cliente
        let newOrder = ClientOrder(clientName: clientName, date: Date(), items: orders)
        
        // 3. Adicionar na lista geral de pedidos
        clientOrders.append(newOrder)
        
        // 4. Limpar o pedido atual para próximo
        orders.removeAll()
        clientName = ""
        
        // 5. Atualizar as listas de compra e pendentes com todos os pedidos
        generatePurchaseSuggestionsFromAllOrders()
        
        print("Pedido salvo com sucesso!")
        saveClientOrdersToDisk()
    }
    
    /// PURCHASE LIST TOTAL
    func generatePurchaseListText() -> String {
        // 1. Agrupar todos os pedidos por produto somando quantidades
        var productTotals: [Product: Double] = [:]
        for order in clientOrders {
            for item in order.items {
                productTotals[item.product, default: 0] += item.quantity
            }
        }
        
        // 2. Montar o texto de compra
        var text = "📋 Lista de Compra\n\n"
        for (product, totalQuantity) in productTotals {
            let unitsPerPackage = Double(product.unitsPerPackage)
            let packages = Int(totalQuantity / unitsPerPackage) // arredonda pra baixo
            let remainder = totalQuantity.truncatingRemainder(dividingBy: unitsPerPackage)
            
            text += "- \(product.name) \(product.brand ?? ""): \(packages) \(product.packageType)(s)"
            if remainder > 0 {
                text += " (restam \(String(format: "%.2f", remainder)) unidades)\n"
            } else {
                text += "\n"
            }
        }

        // 3. Informar clientes que contribuíram com produtos que não completam pacote
        var clientObservations: [String: [String]] = [:]

        for order in clientOrders {
            for item in order.items {
                let totalQuantity = productTotals[item.product] ?? 0
                let remainder = totalQuantity.truncatingRemainder(dividingBy: Double(item.product.unitsPerPackage))
                if remainder > 0 {
                    clientObservations[order.clientName, default: []].append(item.product.name)
                }
            }
        }

        text += "\n🔍 Observações:\n"
        for (client, products) in clientObservations {
            let uniqueProducts = Set(products)
            let productList = uniqueProducts.joined(separator: ", ")
            text += "- \(client) ficará com produto(s) pendente(s): \(productList)\n"
        }

        return text
    }
    
    func removeClientOrder(at offsets: IndexSet) {
        clientOrders.remove(atOffsets: offsets)
        saveClientOrdersToDisk()
    }
    
    /// CALL TEXT (SENT TO CLIENT)
    func receiptText(for order: ClientOrder) -> String {
        return OrderMessageGenerator.generateReceipt(for: order)
    }

    /// Lucro total considerando todos os pedidos de todos os clientes
    var totalProfitFromAllClientOrders: Double {
        clientOrders.reduce(0) { total, clientOrder in
            total + clientOrder.items.reduce(0) { subtotal, item in
                subtotal + (item.product.sellingPrice - item.product.purchasePrice) * item.quantity
            }
        }
    }
}

#warning("Reparar e habilitar cálculo")
/// Valor total (preço de venda) de todos os pedidos de todos os clientes
//var totalPriceFromAllClientOrders: Double {
//    clientOrders.reduce(0) { total, clientOrder in
//        total + clientOrder.items.reduce(0) { subtotal, item in
//            subtotal + (item.product.sellingPrice * item.quantity)
//        }
//    }
//}

// MARK: - Persistência com FileManager + JSON

private extension OrderViewModel {
    var clientOrdersFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("clientOrders.json")
    }

    func saveClientOrdersToDisk() {
        do {
            let data = try JSONEncoder().encode(clientOrders)
            try data.write(to: clientOrdersFileURL)
            print("✅ Pedidos salvos com sucesso.")
        } catch {
            print("❌ Erro ao salvar pedidos: \(error)")
        }
       func loadClientOrdersFromDisk() {     do {
            let data = try Data(contentsOf: clientOrdersFileURL)
            let savedOrders = try JSONDecoder().decode([ClientOrder].self, from: data)
            clientOrders = savedOrders
            print("📥 Pedidos carregados com sucesso.")
        } catch {
            print("⚠️ Nenhum pedido salvo encontrado ou erro ao carregar: \(error)")
        }
    }
}
