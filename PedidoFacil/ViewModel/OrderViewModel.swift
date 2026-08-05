//
//  OrderViewModel.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-17.
//

import Foundation
import OSLog
import SwiftUI

@MainActor
class OrderViewModel: ObservableObject {
    @Published var quantityKg: String = "" {
        didSet { scheduleDraftSave() }
    }
    @Published var totalPrice: Double = 0.0
    @Published var totalProfit: Double = 0.0
    @Published var selectedProduct: Product = OrderViewModel.placeholderProduct {
        didSet { scheduleDraftSave() }
    }
    @Published var orders: [OrderItem] = [] {
        didSet { scheduleDraftSave() }
    }
    @Published var showingCalculation: Bool = false
    @Published var purchaseList: [Product] = []
    @Published var pendingList: [Product] = []
    @Published var clientName: String = "" {
        didSet { scheduleDraftSave() }
    }
    @Published var clientOrders: [ClientOrder] = []
    @Published var showClientNameField: Bool = false
    @Published var receiptText: String = ""

    private let clientOrdersStore: JSONFileStore<[ClientOrder]>
    private let draftStore: JSONFileStore<SalesOrderDraft>
    private var draftSaveTask: Task<Void, Never>?
    private var isRestoringDraft = false
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "PedidoFacil",
        category: "OrderPersistence"
    )
    
    init(
        clientOrdersStore: JSONFileStore<[ClientOrder]>? = nil,
        draftStore: JSONFileStore<SalesOrderDraft>? = nil
    ) {
        self.clientOrdersStore = clientOrdersStore
            ?? JSONFileStore(fileURL: Self.defaultClientOrdersFileURL)
        self.draftStore = draftStore
            ?? JSONFileStore(fileURL: Self.defaultDraftFileURL)
        loadClientOrdersFromDisk()
        loadDraftFromDisk()
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
        generatePurchaseSuggestions()
    }
    
    /// CLEAN ORDER
    func clearAllOrders() {
        orders.removeAll()
        purchaseList.removeAll()
        pendingList.removeAll()
        quantityKg = ""
        showingCalculation = false
        selectedProduct = Self.placeholderProduct
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
            let kgPerUnit = Double(product.unitsPerPackage ?? 0)
            guard kgPerUnit > 0 else { continue }
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
            let kgPerUnit = Double(product.unitsPerPackage ?? 0)
            guard kgPerUnit > 0 else { continue }
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
        selectedProduct = Self.placeholderProduct
        saveDraftImmediately()
    }

    func saveDraftImmediately() {
        draftSaveTask?.cancel()
        guard !isRestoringDraft else { return }

        let selectedProductForDraft = selectedProduct.id == Self.placeholderProduct.id
            ? nil
            : selectedProduct
        let draft = SalesOrderDraft(
            clientName: clientName,
            items: orders,
            quantityInput: quantityKg,
            selectedProduct: selectedProductForDraft,
            updatedAt: Date()
        )

        do {
            try draftStore.save(draft)
            logger.debug("Order draft saved. Item count: \(draft.items.count, privacy: .public)")
        } catch {
            logger.error("Failed to save order draft: \(error.localizedDescription, privacy: .public)")
        }
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
            let unitsPerPackage = Double(product.unitsPerPackage ?? 0)
            guard unitsPerPackage > 0 else {
                text += "- \(product.name) \(product.brand ?? ""): sem unidade por embalagem configurada\n"
                continue
            }
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
                let unitsPerPackage = Double(item.product.unitsPerPackage ?? 0)
                guard unitsPerPackage > 0 else { continue }
                let remainder = totalQuantity.truncatingRemainder(dividingBy: unitsPerPackage)
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
        generatePurchaseSuggestionsFromAllOrders()
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
    
    /// Valor total (preço de venda) de todos os pedidos de todos os clientes
    var totalPriceFromAllClientOrders: Double {
        clientOrders.reduce(0) { total, clientOrder in
            let clientTotal = clientOrder.items.reduce(0) { subtotal, item in
                subtotal + (item.product.sellingPrice * item.quantity)
            }
            return total + clientTotal
        }
    }
}

// MARK: - Persistência com FileManager + JSON

private extension OrderViewModel {
    static let placeholderProduct = Product(
        name: "Selecione um produto",
        purchasePrice: 0,
        sellingPrice: 0,
        packageType: "",
        packageSize: "",
        unitsPerPackage: 1,
        category: ""
    )

    static var defaultClientOrdersFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("clientOrders.json")
    }

    static var defaultDraftFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("currentOrderDraft.json")
    }

    func scheduleDraftSave() {
        guard !isRestoringDraft else { return }
        draftSaveTask?.cancel()
        draftSaveTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            self?.saveDraftImmediately()
        }
    }

    func loadDraftFromDisk() {
        isRestoringDraft = true
        defer { isRestoringDraft = false }

        do {
            guard let draft = try draftStore.load()?.value, !draft.isEmpty else {
                return
            }
            clientName = draft.clientName
            orders = draft.items
            quantityKg = draft.quantityInput
            selectedProduct = draft.selectedProduct ?? Self.placeholderProduct
            generatePurchaseSuggestions()
            logger.info("Order draft restored. Item count: \(draft.items.count, privacy: .public)")
        } catch {
            logger.error("Failed to restore order draft: \(error.localizedDescription, privacy: .public)")
        }
    }

    func saveClientOrdersToDisk() {
        do {
            try clientOrdersStore.save(clientOrders)
            logger.info("Orders saved. Count: \(self.clientOrders.count, privacy: .public)")
        } catch {
            logger.error("Failed to save orders: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    func loadClientOrdersFromDisk() {
        do {
            guard let result = try clientOrdersStore.load() else {
                logger.info("No persisted orders found.")
                return
            }
            clientOrders = result.value
            logger.info(
                "Orders loaded. Count: \(self.clientOrders.count, privacy: .public), legacy: \(result.source.isLegacy, privacy: .public)"
            )
            if result.source.recoveredFromBackup {
                logger.error("Orders recovered from backup.")
            }
        } catch {
            logger.error("Failed to load orders: \(error.localizedDescription, privacy: .public)")
        }
    }
}
