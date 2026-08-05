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

    private func temporaryStore() -> JSONFileStore<[Customer]> {
        JSONFileStore(
            fileURL: FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathComponent("customers.json")
        )
    }
}
