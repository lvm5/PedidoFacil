import XCTest
@testable import PedidoFacil

final class JSONFileStoreTests: XCTestCase {
    private var directoryURL: URL!

    override func setUpWithError() throws {
        directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
    }

    override func tearDownWithError() throws {
        try FileManager.default.removeItem(at: directoryURL)
        directoryURL = nil
    }

    func testLoadsPublishedLegacyArrayWithoutRewritingIt() throws {
        let fileURL = directoryURL.appendingPathComponent("products.json")
        let products = [makeProduct(name: "Produto legado")]
        let legacyData = try JSONEncoder().encode(products)
        try legacyData.write(to: fileURL)
        let store = JSONFileStore<[Product]>(fileURL: fileURL)

        let result = try XCTUnwrap(store.load())

        XCTAssertEqual(result.value.map(\.name), ["Produto legado"])
        XCTAssertEqual(result.source, .primaryLegacy)
        XCTAssertEqual(try Data(contentsOf: fileURL), legacyData)
    }

    func testSaveCreatesVersionedEnvelopeAndLegacyBackup() throws {
        let fileURL = directoryURL.appendingPathComponent("products.json")
        let legacyProducts = [makeProduct(name: "Antes")]
        let legacyData = try JSONEncoder().encode(legacyProducts)
        try legacyData.write(to: fileURL)
        let store = JSONFileStore<[Product]>(fileURL: fileURL)
        let updatedProducts = [makeProduct(name: "Depois")]

        try store.save(updatedProducts, now: Date(timeIntervalSince1970: 123))

        let result = try XCTUnwrap(store.load())
        XCTAssertEqual(result.value.map(\.name), ["Depois"])
        XCTAssertEqual(result.source, .primaryEnvelope)
        XCTAssertEqual(try Data(contentsOf: store.backupURL), legacyData)
    }

    func testCorruptPrimaryRecoversLastValidBackup() throws {
        let fileURL = directoryURL.appendingPathComponent("orders.json")
        let store = JSONFileStore<[ClientOrder]>(fileURL: fileURL)
        let first = [makeOrder(clientName: "Primeiro")]
        let second = [makeOrder(clientName: "Segundo")]
        try store.save(first)
        try store.save(second)
        try Data("arquivo inválido".utf8).write(to: fileURL, options: [.atomic])

        let result = try XCTUnwrap(store.load())

        XCTAssertEqual(result.value.map(\.clientName), ["Primeiro"])
        XCTAssertEqual(result.source, .backupEnvelope)
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

    private func makeOrder(clientName: String) -> ClientOrder {
        ClientOrder(
            clientName: clientName,
            date: Date(timeIntervalSince1970: 123),
            items: [OrderItem(product: makeProduct(name: "Produto"), quantity: 1)]
        )
    }
}
