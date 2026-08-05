import XCTest
@testable import PedidoFacil

final class PersistentIdentityTests: XCTestCase {
    func testOrderAndItemIDsSurviveEncodingRoundTrip() throws {
        let product = Product(
            name: "Mussarela",
            purchasePrice: 30,
            sellingPrice: 36.49,
            packageType: "Kg",
            packageSize: "1kg",
            unitsPerPackage: 1,
            category: "Frios",
            brand: "São Leopoldo"
        )
        let itemID = UUID()
        let orderID = UUID()
        let order = ClientOrder(
            id: orderID,
            clientName: "Cliente teste",
            date: Date(timeIntervalSince1970: 1_700_000_000),
            items: [OrderItem(id: itemID, product: product, quantity: 2)]
        )

        let data = try JSONEncoder().encode(order)
        let decoded = try JSONDecoder().decode(ClientOrder.self, from: data)

        XCTAssertEqual(decoded.id, orderID)
        XCTAssertEqual(decoded.items.first?.id, itemID)
    }

    func testLegacyOrderWithoutIDsStillDecodes() throws {
        let product = Product(
            name: "Presunto",
            purchasePrice: 15,
            sellingPrice: 18.79,
            packageType: "Kg",
            packageSize: "1kg",
            unitsPerPackage: 1,
            category: "Frios",
            brand: "Rezende"
        )
        let productObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(product)) as? [String: Any]
        )
        let legacyObject: [String: Any] = [
            "clientName": "Cliente legado",
            "date": 0,
            "items": [[
                "product": productObject,
                "quantity": 3
            ]]
        ]
        let data = try JSONSerialization.data(withJSONObject: legacyObject)

        let decoded = try JSONDecoder().decode(ClientOrder.self, from: data)

        XCTAssertFalse(decoded.id.uuidString.isEmpty)
        XCTAssertFalse(try XCTUnwrap(decoded.items.first).id.uuidString.isEmpty)
    }
}
