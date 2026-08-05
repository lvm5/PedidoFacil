import XCTest
@testable import PedidoFacil

final class SalesOrderTests: XCTestCase {
    func testDecimalTotalsAndDiscountAreExact() {
        let item = SalesOrderItem(
            productName: "Mussarela",
            brand: "São Leopoldo",
            quantity: decimal("3"),
            unit: "kg",
            listPrice: decimal("36.49"),
            negotiatedPrice: decimal("35.00")
        )
        let order = SalesOrder(customerName: "Mercado", items: [item])

        XCTAssertEqual(item.listSubtotal, decimal("109.47"))
        XCTAssertEqual(item.negotiatedSubtotal, decimal("105.00"))
        XCTAssertEqual(item.totalDifference, decimal("4.47"))
        XCTAssertEqual(order.totalDifference, decimal("4.47"))
    }

    func testConfirmWithoutAdjustmentBecomesReadyToSubmit() throws {
        let item = makeItem(list: "18.79", negotiated: "18.79")
        var order = SalesOrder(customerName: "Cliente", items: [item])

        try order.confirm(at: Date(timeIntervalSince1970: 100))

        XCTAssertEqual(order.status, .readyToSubmit)
        XCTAssertEqual(order.statusHistory.map(\.status), [.draft, .confirmed, .readyToSubmit])
    }

    func testConfirmWithAdjustmentWaitsForExplicitResolution() throws {
        let item = makeItem(list: "18.79", negotiated: "17.99")
        var order = SalesOrder(customerName: "Cliente", items: [item])
        try order.confirm(at: Date(timeIntervalSince1970: 100))
        order.createDiscountRequest(reason: "Condição negociada", at: Date(timeIntervalSince1970: 101))

        XCTAssertEqual(order.status, .awaitingDiscountApproval)
        XCTAssertThrowsError(try order.transition(to: .readyToSubmit)) {
            XCTAssertEqual($0 as? SalesOrderTransitionError, .discountResolutionRequired)
        }

        order.markDiscountSent(at: Date(timeIntervalSince1970: 102))
        XCTAssertEqual(order.status, .awaitingDiscountApproval)
        XCTAssertEqual(order.discountRequest?.status, .sent)

        try order.resolveDiscount(as: .adjusted, at: Date(timeIntervalSince1970: 103))
        XCTAssertEqual(order.status, .readyToSubmit)
    }

    func testGeneratingMessageDoesNotChangeApprovalState() throws {
        let item = makeItem(list: "18.79", negotiated: "17.99")
        var order = SalesOrder(customerName: "Cliente", items: [item])
        try order.confirm()
        order.createDiscountRequest(reason: "Cotação")

        let message = DiscountRequestMessageGenerator().generate(for: order)

        XCTAssertTrue(message.contains("AJUSTE DE PREÇO"))
        XCTAssertTrue(message.contains("Presunto — Rezende"))
        XCTAssertTrue(message.contains("R$"))
        XCTAssertTrue(message.contains("Motivo: Cotação"))
        XCTAssertEqual(order.status, .awaitingDiscountApproval)
        XCTAssertEqual(order.discountRequest?.status, .draft)
    }

    func testTerminalOrderRejectsFurtherTransition() throws {
        var order = SalesOrder(customerName: "Cliente")
        try order.transition(to: .cancelled)

        XCTAssertThrowsError(try order.transition(to: .draft)) {
            XCTAssertEqual(
                $0 as? SalesOrderTransitionError,
                .invalidTransition(from: .cancelled, to: .draft)
            )
        }
    }

    private func makeItem(list: String, negotiated: String) -> SalesOrderItem {
        SalesOrderItem(
            productName: "Presunto",
            brand: "Rezende",
            quantity: 2,
            unit: "kg",
            listPrice: decimal(list),
            negotiatedPrice: decimal(negotiated)
        )
    }

    private func decimal(_ value: String) -> Decimal {
        Decimal(string: value, locale: Locale(identifier: "en_US_POSIX"))!
    }
}
