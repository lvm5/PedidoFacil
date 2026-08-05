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
        model.saveReviewedList()
        XCTAssertEqual(model.savedLists.count, 1)
        XCTAssertEqual(model.savedLists.first?.status, .reviewed)
        XCTAssertEqual(try store.load()?.value.count, 1)
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

    private func makeTemporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
