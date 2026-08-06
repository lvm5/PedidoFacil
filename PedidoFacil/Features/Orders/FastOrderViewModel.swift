import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class FastOrderViewModel {
    private(set) var order: SalesOrder
    private(set) var savedOrders: [SalesOrder] = []
    private(set) var errorMessage: String?
    private(set) var successMessage: String?

    var customerName: String
    var selectedCustomerID: UUID?
    var selectedProductID: UUID?
    var quantityText = ""
    var negotiatedPriceText = ""
    var itemNote = ""
    var discountReason = ""

    private(set) var products: [Product]
    private(set) var customers: [Customer]

    private let store: JSONFileStore<[SalesOrder]>
    private let messageGenerator: DiscountRequestMessageGenerator
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "PedidoFacil",
        category: "FastOrder"
    )

    init(
        products: [Product],
        customers: [Customer] = [],
        store: JSONFileStore<[SalesOrder]>? = nil,
        locale: Locale = Locale(identifier: "pt_BR")
    ) {
        self.products = products.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        self.customers = customers.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        self.store = store ?? JSONFileStore(fileURL: Self.defaultFileURL)
        messageGenerator = DiscountRequestMessageGenerator(locale: locale)

        let persistedOrders: [SalesOrder]
        do {
            persistedOrders = try self.store.load()?.value ?? []
        } catch {
            persistedOrders = []
            errorMessage = "Não foi possível carregar os pedidos comerciais."
            logger.error("Failed to load sales orders: \(error.localizedDescription, privacy: .public)")
        }
        savedOrders = persistedOrders
        if let draft = persistedOrders.last(where: { $0.status == .draft }) {
            order = draft
            customerName = draft.customerName
            selectedCustomerID = draft.customerID
        } else {
            order = SalesOrder(customerName: "")
            customerName = ""
            selectedCustomerID = nil
        }
    }

    var selectedProduct: Product? {
        products.first { $0.id == selectedProductID }
    }

    var selectedCustomer: Customer? {
        customers.first { $0.id == selectedCustomerID }
    }

    var discountMessage: String {
        messageGenerator.generate(for: order)
    }

    var previousOrders: [SalesOrder] {
        savedOrders
            .filter { $0.id != order.id && $0.status != .draft && $0.status != .cancelled }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    var previouslyPurchasedProductIDs: Set<UUID> {
        guard let selectedCustomerID else { return [] }
        return Set(
            savedOrders
                .filter { $0.customerID == selectedCustomerID }
                .flatMap(\.items)
                .compactMap(\.productID)
        )
    }

    var canAddItem: Bool {
        selectedProduct != nil
            && parsePositiveDecimal(quantityText) != nil
            && parsePositiveDecimal(effectiveNegotiatedPriceText) != nil
            && order.status == .draft
    }

    var canConfirm: Bool {
        !customerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !order.items.isEmpty
            && (!order.requiresPriceAdjustment
                || !discountReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            && order.status == .draft
    }

    func selectProduct(_ id: UUID?) {
        selectedProductID = id
        if let selectedProduct {
            negotiatedPriceText = Self.decimalString(from: selectedProduct.sellingPrice)
        } else {
            negotiatedPriceText = ""
        }
    }

    func updateCustomerName(_ name: String) {
        selectedCustomerID = nil
        customerName = name
        order.customerID = nil
        order.customerName = name
        order.updatedAt = Date()
        persistOrder()
    }

    func selectCustomer(_ id: UUID?) {
        selectedCustomerID = id
        guard let customer = customers.first(where: { $0.id == id }) else {
            updateCustomerName("")
            return
        }
        customerName = customer.name
        order.customerID = customer.id
        order.customerName = customer.name
        order.updatedAt = Date()
        persistOrder()
    }

    func updateCustomers(_ customers: [Customer]) {
        self.customers = customers.sorted {
            $0.name.localizedCompare($1.name) == .orderedAscending
        }
        if let selectedCustomerID,
           !self.customers.contains(where: { $0.id == selectedCustomerID }) {
            self.selectedCustomerID = nil
            order.customerID = nil
        }
    }

    func updateProducts(_ products: [Product]) {
        self.products = products.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        if let selectedProductID,
           !self.products.contains(where: { $0.id == selectedProductID }) {
            self.selectedProductID = nil
            negotiatedPriceText = ""
        }
    }

    func addItem() {
        guard let product = selectedProduct,
              let quantity = parsePositiveDecimal(quantityText),
              let negotiatedPrice = parsePositiveDecimal(effectiveNegotiatedPriceText) else {
            errorMessage = "Selecione o produto e informe quantidade e preço válidos."
            return
        }
        let listPrice = Self.decimal(from: product.sellingPrice)
        order.items.append(
            SalesOrderItem(
                productID: product.id,
                productName: product.name,
                brand: product.brand,
                quantity: quantity,
                unit: product.packageType ?? "un",
                listPrice: listPrice,
                negotiatedPrice: negotiatedPrice,
                note: itemNote.trimmingCharacters(in: .whitespacesAndNewlines).nilIfBlank
            )
        )
        order.customerName = customerName
        order.updatedAt = Date()
        quantityText = ""
        itemNote = ""
        errorMessage = nil
        persistOrder()
    }

    func removeItem(id: UUID) {
        guard order.status == .draft else { return }
        order.items.removeAll { $0.id == id }
        order.updatedAt = Date()
        persistOrder()
    }

    func confirmOrder() {
        guard canConfirm else {
            errorMessage = order.requiresPriceAdjustment && discountReason.nilIfBlank == nil
                ? "Informe o motivo do ajuste de preço."
                : "Informe o cliente e adicione pelo menos um item."
            return
        }

        order.customerName = customerName.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            try order.confirm()
            if order.requiresPriceAdjustment {
                order.createDiscountRequest(reason: discountReason)
            }
            errorMessage = nil
            successMessage = order.requiresPriceAdjustment
                ? "Pedido aguardando ajuste de preço."
                : "Pedido pronto para lançamento."
            persistOrder()
        } catch {
            errorMessage = "Não foi possível confirmar o pedido."
            logger.error("Failed to confirm order: \(error.localizedDescription, privacy: .public)")
        }
    }

    func markDiscountSent() {
        guard order.status == .awaitingDiscountApproval else { return }
        order.markDiscountSent()
        successMessage = "Solicitação marcada como enviada. A aprovação ainda está pendente."
        persistOrder()
    }

    func resolveDiscount(as resolution: DiscountRequestStatus) {
        do {
            try order.resolveDiscount(as: resolution)
            successMessage = resolution == .refused
                ? "Ajuste recusado. Revise ou cancele o pedido."
                : "Ajuste resolvido. Pedido pronto para lançamento."
            persistOrder()
        } catch {
            errorMessage = "Não foi possível atualizar o ajuste."
        }
    }

    func markSubmitted() {
        transition(to: .submitted, success: "Pedido marcado como lançado.")
    }

    func complete() {
        transition(to: .completed, success: "Pedido concluído.")
    }

    func cancelOrder() {
        transition(to: .cancelled, success: "Pedido cancelado.")
    }

    func startNewOrder() {
        order = SalesOrder(customerName: "")
        customerName = ""
        selectedCustomerID = nil
        selectedProductID = nil
        quantityText = ""
        negotiatedPriceText = ""
        itemNote = ""
        discountReason = ""
        errorMessage = nil
        successMessage = nil
        persistOrder()
    }

    func duplicateOrder(id: UUID, now: Date = Date()) {
        guard let source = savedOrders.first(where: { $0.id == id }) else {
            errorMessage = "Pedido anterior não encontrado."
            return
        }
        let copiedItems = source.items.map {
            SalesOrderItem(
                productID: $0.productID,
                productName: $0.productName,
                brand: $0.brand,
                quantity: $0.quantity,
                unit: $0.unit,
                listPrice: $0.listPrice,
                negotiatedPrice: $0.negotiatedPrice,
                note: $0.note
            )
        }
        order = SalesOrder(
            customerID: source.customerID,
            customerName: source.customerName,
            createdAt: now,
            updatedAt: now,
            items: copiedItems,
            note: source.note
        )
        customerName = source.customerName
        selectedCustomerID = source.customerID
        selectedProductID = nil
        quantityText = ""
        negotiatedPriceText = ""
        discountReason = ""
        errorMessage = nil
        successMessage = "Pedido anterior duplicado como novo rascunho."
        persistOrder()
    }

    private var effectiveNegotiatedPriceText: String {
        negotiatedPriceText.nilIfBlank
            ?? selectedProduct.map { Self.decimalString(from: $0.sellingPrice) }
            ?? ""
    }

    private func transition(to status: SalesOrderStatus, success: String) {
        do {
            try order.transition(to: status)
            successMessage = success
            errorMessage = nil
            persistOrder()
        } catch {
            errorMessage = "Esta mudança de status não é permitida agora."
        }
    }

    private func persistOrder() {
        if let index = savedOrders.firstIndex(where: { $0.id == order.id }) {
            savedOrders[index] = order
        } else {
            savedOrders.append(order)
        }

        do {
            try store.save(savedOrders)
            logger.debug("Sales order persisted. Status: \(self.order.status.rawValue, privacy: .public)")
        } catch {
            errorMessage = "Não foi possível salvar o pedido. Tente novamente."
            logger.error("Failed to persist sales order: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func parsePositiveDecimal(_ text: String) -> Decimal? {
        let sanitized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true
        let value = (formatter.number(from: sanitized) as? NSDecimalNumber)?.decimalValue
            ?? Decimal(string: sanitized.replacingOccurrences(of: ",", with: "."))
        guard let value, value > 0 else { return nil }
        return value
    }

    private static func decimal(from value: Double) -> Decimal {
        Decimal(string: String(value), locale: Locale(identifier: "en_US_POSIX")) ?? 0
    }

    private static func decimalString(from value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }

    private static var defaultFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("salesOrders.json")
    }
}

private extension String {
    var nilIfBlank: String? {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
