import XCTest
@testable import PedidoFacil

@MainActor
final class FastOrderViewModelTests: XCTestCase {
    func testDraftRecoversAndOrderWithoutDiscountBecomesReady() throws {
        let context = try makeContext()
        defer { try? FileManager.default.removeItem(at: context.directory) }
        let product = makeProduct()
        var model: FastOrderViewModel? = FastOrderViewModel(products: [product], store: context.store)
        model?.updateCustomerName("Mercado Central")
        model?.selectProduct(product.id)
        model?.quantityText = "2"
        model?.addItem()
        model = nil

        let restored = FastOrderViewModel(products: [product], store: context.store)
        XCTAssertEqual(restored.customerName, "Mercado Central")
        XCTAssertEqual(restored.order.items.count, 1)

        restored.confirmOrder()
        XCTAssertEqual(restored.order.status, .readyToSubmit)
    }

    func testNegotiatedPriceRequiresReasonAndExplicitResolution() throws {
        let context = try makeContext()
        defer { try? FileManager.default.removeItem(at: context.directory) }
        let product = makeProduct()
        let model = FastOrderViewModel(products: [product], store: context.store)
        model.updateCustomerName("Restaurante")
        model.selectProduct(product.id)
        model.quantityText = "3"
        model.negotiatedPriceText = "35,00"
        model.addItem()

        model.confirmOrder()
        XCTAssertEqual(model.order.status, .draft)
        XCTAssertEqual(model.errorMessage, "Informe o motivo do ajuste de preço.")

        model.discountReason = "Cotação concorrente"
        model.confirmOrder()
        XCTAssertEqual(model.order.status, .awaitingDiscountApproval)
        XCTAssertEqual(model.order.discountRequest?.status, .draft)

        _ = model.discountMessage
        XCTAssertEqual(model.order.discountRequest?.status, .draft)
        model.markDiscountSent()
        XCTAssertEqual(model.order.discountRequest?.status, .sent)
        XCTAssertEqual(model.order.status, .awaitingDiscountApproval)

        model.resolveDiscount(as: .adjusted)
        XCTAssertEqual(model.order.status, .readyToSubmit)
    }

    func testSubmittedOrderCanCompleteAndPersistsHistory() throws {
        let context = try makeContext()
        defer { try? FileManager.default.removeItem(at: context.directory) }
        let product = makeProduct()
        let model = FastOrderViewModel(products: [product], store: context.store)
        model.updateCustomerName("Padaria")
        model.selectProduct(product.id)
        model.quantityText = "1"
        model.addItem()
        model.confirmOrder()
        model.markSubmitted()
        model.complete()

        let persisted = try XCTUnwrap(context.store.load()?.value.first)
        XCTAssertEqual(persisted.status, .completed)
        XCTAssertEqual(
            persisted.statusHistory.map(\.status),
            [.draft, .confirmed, .readyToSubmit, .submitted, .completed]
        )
    }

    private func makeContext() throws -> (
        directory: URL,
        store: JSONFileStore<[SalesOrder]>
    ) {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return (
            directory,
            JSONFileStore(fileURL: directory.appendingPathComponent("salesOrders.json"))
        )
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
