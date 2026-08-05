import XCTest
@testable import PedidoFacil

@MainActor
final class OrderDuplicationTests: XCTestCase {
    func testDuplicatesPreviousOrderWithNewStableIdentitiesAndDraftStatus() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = JSONFileStore<[SalesOrder]>(
            fileURL: directory.appendingPathComponent("orders.json")
        )
        let customerID = UUID()
        let item = SalesOrderItem(
            productName: "Queijo",
            quantity: 2,
            unit: "kg",
            listPrice: 10
        )
        var previous = SalesOrder(
            customerID: customerID,
            customerName: "Cliente A",
            status: .readyToSubmit,
            items: [item]
        )
        previous.statusHistory = [SalesOrderStatusChange(status: .readyToSubmit, changedAt: Date())]
        try store.save([previous])
        let viewModel = FastOrderViewModel(products: [], store: store)
        let now = Date(timeIntervalSince1970: 500)

        viewModel.duplicateOrder(id: previous.id, now: now)

        XCTAssertNotEqual(viewModel.order.id, previous.id)
        XCTAssertNotEqual(viewModel.order.items.first?.id, previous.items.first?.id)
        XCTAssertEqual(viewModel.order.customerID, customerID)
        XCTAssertEqual(viewModel.order.status, .draft)
        XCTAssertEqual(viewModel.order.createdAt, now)
        XCTAssertEqual(viewModel.order.items.first?.quantity, 2)
        XCTAssertEqual(viewModel.savedOrders.count, 2)
    }

    func testSelectingStructuredCustomerLinksOrderAndFindsRecurringProducts() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = JSONFileStore<[SalesOrder]>(
            fileURL: directory.appendingPathComponent("orders.json")
        )
        let customer = Customer(name: "Cliente B")
        let productID = UUID()
        let previous = SalesOrder(
            customerID: customer.id,
            customerName: customer.name,
            status: .completed,
            items: [
                SalesOrderItem(
                    productID: productID,
                    productName: "Produto recorrente",
                    quantity: 1,
                    unit: "un",
                    listPrice: 5
                )
            ]
        )
        try store.save([previous])
        let viewModel = FastOrderViewModel(products: [], customers: [customer], store: store)

        viewModel.selectCustomer(customer.id)

        XCTAssertEqual(viewModel.order.customerID, customer.id)
        XCTAssertEqual(viewModel.customerName, customer.name)
        XCTAssertEqual(viewModel.previouslyPurchasedProductIDs, [productID])
    }
}
