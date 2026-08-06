import XCTest
@testable import PedidoFacil

@MainActor
final class CustomerStoreTests: XCTestCase {
    func testSavesRestoresAndFiltersCustomers() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let fileStore = JSONFileStore<[Customer]>(
            fileURL: directory.appendingPathComponent("customers.json")
        )
        let store = CustomerStore(store: fileStore)

        let bakery = try XCTUnwrap(store.save(
            name: "Padaria Central",
            segment: "Padaria",
            tags: ["Prioridade", " prioridade ", "Ativo"],
            city: " Botucatu ",
            state: " sp ",
            postalCode: "18600-000",
            street: "Rua das Flores",
            addressNumber: "10",
            neighborhood: "Centro",
            deliveryRoute: "Rota Centro",
            notes: "Compra semanal"
        ))
        _ = store.save(
            name: "Restaurante Sul",
            segment: "Restaurante",
            tags: [],
            city: nil,
            notes: nil
        )

        let restored = CustomerStore(store: fileStore)
        restored.selectedSegment = "Padaria"
        restored.query = "botucatu"

        XCTAssertEqual(restored.activeCustomers.map(\.id), [bakery.id])
        XCTAssertEqual(restored.activeCustomers.first?.tags, ["Ativo", "Prioridade"])
        XCTAssertEqual(restored.activeCustomers.first?.city, "Botucatu")
        XCTAssertEqual(restored.activeCustomers.first?.state, "SP")
        XCTAssertEqual(restored.activeCustomers.first?.deliveryDays, [.tuesday, .wednesday, .thursday])
        XCTAssertEqual(restored.activeCustomers.first?.deliveryRoute, "Rota Centro")
        XCTAssertTrue(restored.activeCustomers.first?.formattedAddress?.contains("Rua das Flores, 10") == true)
    }

    func testArchivePreservesCustomerHistory() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let fileStore = JSONFileStore<[Customer]>(
            fileURL: directory.appendingPathComponent("customers.json")
        )
        let store = CustomerStore(store: fileStore)
        let customer = try XCTUnwrap(store.save(
            name: "Mercado Bairro",
            segment: "Supermercado",
            tags: [],
            city: nil,
            notes: nil
        ))

        store.archive(id: customer.id, now: Date(timeIntervalSince1970: 100))
        let restored = CustomerStore(store: fileStore)

        XCTAssertTrue(restored.activeCustomers.isEmpty)
        XCTAssertEqual(restored.customers.count, 1)
        XCTAssertTrue(try XCTUnwrap(restored.customers.first).isArchived)
    }

    func testRejectsBlankCustomerName() {
        let store = CustomerStore(store: temporaryStore())

        let customer = store.save(
            name: "   ",
            segment: "Outros",
            tags: [],
            city: nil,
            notes: nil
        )

        XCTAssertNil(customer)
        XCTAssertEqual(store.errorMessage, "Informe o nome do cliente.")
    }

    func testSuggestsDeliveryDaysForConfiguredCitiesAndAllowsOverride() throws {
        XCTAssertEqual(DeliveryRouteSuggestion.days(for: "Areiópolis", state: "SP"), [.wednesday])
        XCTAssertEqual(DeliveryRouteSuggestion.days(for: "Itatinga", state: "sp"), [.wednesday])
        XCTAssertEqual(
            DeliveryRouteSuggestion.days(for: "São Manuel", state: "SP"),
            [.tuesday, .wednesday, .thursday]
        )
        XCTAssertTrue(DeliveryRouteSuggestion.days(for: "Outra cidade", state: "SP").isEmpty)

        let store = CustomerStore(store: temporaryStore())
        let customer = try XCTUnwrap(store.save(
            name: "Cliente com rota própria",
            segment: "Outros",
            tags: [],
            city: "Botucatu",
            state: "SP",
            deliveryDays: [.friday],
            notes: nil
        ))
        XCTAssertEqual(customer.deliveryDays, [.friday])
    }

    func testDecodesLegacyCustomerWithoutAddressOrDeliveryFields() throws {
        let data = Data(#"{"id":"00000000-0000-0000-0000-000000000001","name":"Legado","segment":"Outros","tags":[],"city":"Botucatu","createdAt":0,"updatedAt":0}"#.utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let customer = try decoder.decode(Customer.self, from: data)

        XCTAssertEqual(customer.city, "Botucatu")
        XCTAssertNil(customer.street)
        XCTAssertNil(customer.deliveryDays)
    }

    private func temporaryStore() -> JSONFileStore<[Customer]> {
        JSONFileStore(
            fileURL: FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathComponent("customers.json")
        )
    }
}
