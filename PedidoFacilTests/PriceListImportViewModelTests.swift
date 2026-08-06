import XCTest
@testable import PedidoFacil

@MainActor
final class PriceListImportViewModelTests: XCTestCase {
    func testCannotSaveUntilAmbiguousItemIsCorrected() throws {
        let directoryURL = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directoryURL) }
        let store = JSONFileStore<[DailyPriceList]>(
            fileURL: directoryURL.appendingPathComponent("lists.json")
        )
        let model = PriceListImportViewModel(store: store)
        let productStore = JSONFileStore<[Product]>(
            fileURL: directoryURL.appendingPathComponent("products.json")
        )
        let productModel = ProductModel(store: productStore, loadSamplesWhenEmpty: false)
        model.sourceText = "Presunto Rezende R$ 18,79 kg"
        model.reviewSource()
        let item = try XCTUnwrap(model.draft?.items.first)
        XCTAssertFalse(model.canSave)

        model.updateItem(
            id: item.id,
            name: "Presunto",
            brand: "Rezende",
            priceText: "18,79",
            category: "Frios",
            unit: "kg"
        )

        XCTAssertTrue(model.canSave)
        model.saveReviewedList(publishingTo: productModel)
        XCTAssertEqual(model.savedLists.count, 1)
        XCTAssertEqual(model.savedLists.first?.status, .active)
        XCTAssertEqual(try store.load()?.value.count, 1)
        let product = try XCTUnwrap(productModel.products.first)
        XCTAssertEqual(product.name, "Presunto")
        XCTAssertEqual(product.purchasePrice, 18.79, accuracy: 0.001)
        XCTAssertEqual(product.sellingPrice, 18.79, accuracy: 0.001)
        XCTAssertEqual(product.purchasePriceIsProvisional, true)
    }

    func testPublishesValidItemsSkipsPendingAndSurvivesReload() throws {
        let directoryURL = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directoryURL) }
        let listStore = JSONFileStore<[DailyPriceList]>(
            fileURL: directoryURL.appendingPathComponent("lists.json")
        )
        let productStore = JSONFileStore<[Product]>(
            fileURL: directoryURL.appendingPathComponent("products.json")
        )
        let model = PriceListImportViewModel(
            knownBrands: ["Lactopar"],
            store: listStore
        )
        let productModel = ProductModel(store: productStore, loadSamplesWhenEmpty: false)
        model.sourceText = """
        Mussarela Lactopar R$ 35,99 kg
        Produto sem preço Lactopar
        """
        model.reviewSource()

        model.saveReviewedList(publishingTo: productModel)

        XCTAssertEqual(model.savedLists.first?.status, .active)
        XCTAssertEqual(model.savedLists.first?.items.count, 1)
        XCTAssertEqual(productModel.products.count, 1)
        XCTAssertTrue(model.successMessage?.contains("1 pendente(s)") == true)

        let restoredProducts = ProductModel(store: productStore, loadSamplesWhenEmpty: false)
        let restoredLists = PriceListImportViewModel(store: listStore)
        XCTAssertEqual(restoredProducts.products.count, 1)
        XCTAssertEqual(restoredLists.savedLists.first?.status, .active)

        let orderModel = FastOrderViewModel(
            products: [],
            store: JSONFileStore(fileURL: directoryURL.appendingPathComponent("orders.json"))
        )
        orderModel.updateProducts(restoredProducts.products)
        XCTAssertEqual(orderModel.products.first?.name, "Mussarela")
    }

    func testDuplicateMustBeRemovedOrResolvedBeforeSave() throws {
        let directoryURL = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directoryURL) }
        let model = PriceListImportViewModel(
            knownBrands: ["Lar"],
            store: JSONFileStore(fileURL: directoryURL.appendingPathComponent("lists.json"))
        )
        model.sourceText = "Batata Lar R$ 7,99 pct\nBatata Lar R$ 8,19 pct"
        model.reviewSource()
        let secondID = try XCTUnwrap(model.draft?.items.last?.id)
        XCTAssertFalse(model.canSave)

        model.removeItem(id: secondID)

        XCTAssertTrue(model.canSave)
    }

    func testRetryAfterProductFailureDoesNotDuplicateReviewedList() throws {
        let directoryURL = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directoryURL) }
        let listStore = JSONFileStore<[DailyPriceList]>(
            fileURL: directoryURL.appendingPathComponent("lists.json")
        )
        let model = PriceListImportViewModel(knownBrands: ["Marca"], store: listStore)
        let failingProductModel = ProductModel(
            store: JSONFileStore(fileURL: URL(fileURLWithPath: "/dev/null/products.json")),
            loadSamplesWhenEmpty: false
        )
        model.sourceText = "Produto Marca R$ 10,00 kg"
        model.reviewSource()

        model.saveReviewedList(publishingTo: failingProductModel)
        model.saveReviewedList(publishingTo: failingProductModel)

        let stored = try XCTUnwrap(listStore.load()?.value)
        XCTAssertEqual(stored.count, 1)
        XCTAssertEqual(stored.first?.status, .reviewed)
    }

    private func makeTemporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
