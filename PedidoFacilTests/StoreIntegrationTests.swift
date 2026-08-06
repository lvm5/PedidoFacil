import XCTest
@testable import PedidoFacil

@MainActor
final class StoreIntegrationTests: XCTestCase {
    func testProductModelLoadsPublishedLegacyFileAndWritesEnvelopeOnEdit() throws {
        let directoryURL = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directoryURL) }
        let fileURL = directoryURL.appendingPathComponent("products.json")
        let store = JSONFileStore<[Product]>(fileURL: fileURL)
        let legacyProduct = makeProduct(name: "Legado")
        try JSONEncoder().encode([legacyProduct]).write(to: fileURL)

        let model = ProductModel(store: store)
        model.add(makeProduct(name: "Novo"))

        XCTAssertEqual(model.products.map(\.name), ["Legado", "Novo"])
        let result = try XCTUnwrap(store.load())
        XCTAssertEqual(result.source, .primaryEnvelope)
        XCTAssertEqual(result.value.map(\.name), ["Legado", "Novo"])
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.backupURL.path))
    }

    func testOrderViewModelPersistsCompletedOrderThroughVersionedStore() throws {
        let directoryURL = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directoryURL) }
        let store = JSONFileStore<[ClientOrder]>(
            fileURL: directoryURL.appendingPathComponent("clientOrders.json")
        )
        let model = OrderViewModel(clientOrdersStore: store)
        model.clientName = "Cliente teste"
        model.orders = [OrderItem(product: makeProduct(name: "Produto"), quantity: 2)]

        model.saveClientOrder()

        let result = try XCTUnwrap(store.load())
        XCTAssertEqual(result.source, .primaryEnvelope)
        XCTAssertEqual(result.value.count, 1)
        XCTAssertEqual(result.value.first?.clientName, "Cliente teste")
    }

    func testOrderViewModelKeepsDraftWhenCompletedOrderCannotPersist() {
        let store = JSONFileStore<[ClientOrder]>(
            fileURL: URL(fileURLWithPath: "/dev/null/clientOrders.json")
        )
        let model = OrderViewModel(clientOrdersStore: store)
        model.clientName = "Cliente teste"
        model.orders = [OrderItem(product: makeProduct(name: "Produto"), quantity: 2)]

        model.saveClientOrder()

        XCTAssertTrue(model.clientOrders.isEmpty)
        XCTAssertEqual(model.clientName, "Cliente teste")
        XCTAssertEqual(model.orders.count, 1)
        XCTAssertNotNil(model.errorMessage)
    }

    func testLegacyOrderAcceptsBrazilianDecimalQuantity() {
        let model = OrderViewModel()
        model.selectedProduct = makeProduct(name: "Produto")
        model.quantityKg = "1,5"

        model.calculate()

        XCTAssertEqual(model.totalPrice, 18, accuracy: 0.001)
        XCTAssertTrue(model.showingCalculation)
        XCTAssertNil(model.errorMessage)
    }

    func testProductFailureKeepsPublishedCollectionUnchanged() {
        let model = ProductModel(
            store: JSONFileStore(fileURL: URL(fileURLWithPath: "/dev/null/products.json")),
            loadSamplesWhenEmpty: false
        )

        model.add(makeProduct(name: "Não persistido"))

        XCTAssertTrue(model.products.isEmpty)
        XCTAssertNotNil(model.persistenceErrorMessage)
    }

    func testRemovingOrdersByIdentityIsIndependentFromVisibleSortOrder() throws {
        let directoryURL = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directoryURL) }
        let store = JSONFileStore<[ClientOrder]>(fileURL: directoryURL.appendingPathComponent("orders.json"))
        let model = OrderViewModel(clientOrdersStore: store)
        let older = ClientOrder(
            clientName: "Antigo",
            date: Date(timeIntervalSince1970: 100),
            items: [OrderItem(product: makeProduct(name: "A"), quantity: 1)]
        )
        let newer = ClientOrder(
            clientName: "Novo",
            date: Date(timeIntervalSince1970: 200),
            items: [OrderItem(product: makeProduct(name: "B"), quantity: 1)]
        )
        model.clientOrders = [older, newer]

        model.removeClientOrders(ids: [newer.id])

        XCTAssertEqual(model.clientOrders.map(\.id), [older.id])
    }

    private func makeTemporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func makeProduct(name: String) -> Product {
        Product(
            name: name,
            purchasePrice: 10,
            sellingPrice: 12,
            packageType: "Unidade",
            packageSize: "1 un",
            unitsPerPackage: 1,
            category: "Teste"
        )
    }
}
