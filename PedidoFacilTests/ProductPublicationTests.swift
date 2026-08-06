import XCTest
@testable import PedidoFacil

@MainActor
final class ProductPublicationTests: XCTestCase {
    func testPublishingAgainUpdatesSaleAndProvisionalPurchaseWithoutDuplicating() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let model = ProductModel(
            store: JSONFileStore(fileURL: directory.appendingPathComponent("products.json")),
            loadSamplesWhenEmpty: false
        )
        let first = list(price: "10.00")
        let second = list(price: "12.00")

        XCTAssertEqual(try model.publish(first), ProductPublicationSummary(created: 1, updated: 0))
        XCTAssertEqual(try model.publish(second), ProductPublicationSummary(created: 0, updated: 1))
        XCTAssertEqual(model.products.count, 1)
        XCTAssertEqual(model.products[0].purchasePrice, 12, accuracy: 0.001)
        XCTAssertEqual(model.products[0].sellingPrice, 12, accuracy: 0.001)
        XCTAssertEqual(model.products[0].purchasePriceIsProvisional, true)
    }

    func testPublishingPreservesConfirmedPurchasePrice() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = JSONFileStore<[Product]>(fileURL: directory.appendingPathComponent("products.json"))
        try store.save([
            Product(
                name: "Batata",
                purchasePrice: 7,
                sellingPrice: 9,
                packageType: "Kg",
                packageSize: "10kg",
                unitsPerPackage: 1,
                category: "Congelados",
                brand: "Lar",
                purchasePriceIsProvisional: false
            )
        ])
        let model = ProductModel(store: store, loadSamplesWhenEmpty: false)

        _ = try model.publish(list(name: "Batata", brand: "Lar", unit: "10kg", price: "11.00"))

        XCTAssertEqual(model.products[0].purchasePrice, 7, accuracy: 0.001)
        XCTAssertEqual(model.products[0].sellingPrice, 11, accuracy: 0.001)
        XCTAssertEqual(model.products[0].purchasePriceIsProvisional, false)
    }

    private func list(
        name: String = "Mussarela",
        brand: String = "Lactopar",
        unit: String = "24kg",
        price: String
    ) -> DailyPriceList {
        DailyPriceList(
            sourceText: "fixture",
            status: .reviewed,
            items: [
                PriceListItem(
                    sourceLineNumber: 1,
                    originalLine: "fixture",
                    name: name,
                    brand: brand,
                    price: Decimal(string: price),
                    unit: unit,
                    category: "Laticínios"
                )
            ]
        )
    }
}
