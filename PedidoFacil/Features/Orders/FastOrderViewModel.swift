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
    var selectedProductID: UUID?
    var quantityText = ""
    var negotiatedPriceText = ""
    var itemNote = ""
    var discountReason = ""

    let products: [Product]

    private let store: JSONFileStore<[SalesOrder]>
    private let messageGenerator: DiscountRequestMessageGenerator
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "PedidoFacil",
        category: "FastOrder"
    )

    init(
        products: [Product],
        store: JSONFileStore<[SalesOrder]>? = nil,
        locale: Locale = Locale(identifier: "pt_BR")
    ) {
        self.products = products.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
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
        } else {
            order = SalesOrder(customerName: "")
            customerName = ""
        }
    }

    var selectedProduct: Product? {
        products.first { $0.id == selectedProductID }
    }

    var discountMessage: String {
        messageGenerator.generate(for: order)
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
        customerName = name
        order.customerName = name
        order.updatedAt = Date()
        persistOrder()
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
        selectedProductID = nil
        quantityText = ""
        negotiatedPriceText = ""
        itemNote = ""
        discountReason = ""
        errorMessage = nil
        successMessage = nil
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
