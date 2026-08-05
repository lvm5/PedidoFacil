import XCTest
@testable import PedidoFacil

@MainActor
final class OrderDraftRecoveryTests: XCTestCase {
    func testDraftRestoresAfterViewModelReinitialization() throws {
        let directoryURL = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directoryURL) }
        let ordersStore = JSONFileStore<[ClientOrder]>(
            fileURL: directoryURL.appendingPathComponent("orders.json")
        )
        let draftStore = JSONFileStore<SalesOrderDraft>(
            fileURL: directoryURL.appendingPathComponent("draft.json")
        )
        let product = makeProduct()
        var original: OrderViewModel? = OrderViewModel(
            clientOrdersStore: ordersStore,
            draftStore: draftStore
        )
        original?.clientName = "Cliente recuperado"
        original?.selectedProduct = product
        original?.quantityKg = "2,5"
        original?.orders = [OrderItem(product: product, quantity: 1)]
        original?.saveDraftImmediately()
        original = nil

        let restored = OrderViewModel(
            clientOrdersStore: ordersStore,
            draftStore: draftStore
        )

        XCTAssertEqual(restored.clientName, "Cliente recuperado")
        XCTAssertEqual(restored.selectedProduct.id, product.id)
        XCTAssertEqual(restored.quantityKg, "2,5")
        XCTAssertEqual(restored.orders.count, 1)
        XCTAssertEqual(restored.orders.first?.product.id, product.id)
    }

    func testCompletedOrderLeavesNoRecoverableDraft() throws {
        let directoryURL = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directoryURL) }
        let ordersStore = JSONFileStore<[ClientOrder]>(
            fileURL: directoryURL.appendingPathComponent("orders.json")
        )
        let draftStore = JSONFileStore<SalesOrderDraft>(
            fileURL: directoryURL.appendingPathComponent("draft.json")
        )
        let model = OrderViewModel(clientOrdersStore: ordersStore, draftStore: draftStore)
        model.clientName = "Cliente concluído"
        model.orders = [OrderItem(product: makeProduct(), quantity: 1)]

        model.saveClientOrder()

        let restored = OrderViewModel(clientOrdersStore: ordersStore, draftStore: draftStore)
        XCTAssertTrue(restored.clientName.isEmpty)
        XCTAssertTrue(restored.orders.isEmpty)
        XCTAssertEqual(restored.clientOrders.count, 1)
    }

    private func makeTemporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func makeProduct() -> Product {
        Product(
            name: "Mussarela",
            purchasePrice: 30,
            sellingPrice: 36.49,
            packageType: "Kg",
            packageSize: "1kg",
            unitsPerPackage: 1,
            category: "Frios",
            brand: "São Leopoldo"
        )
    }
}
