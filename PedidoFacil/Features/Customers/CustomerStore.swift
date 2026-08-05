import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class CustomerStore {
    private(set) var customers: [Customer] = []
    private(set) var errorMessage: String?

    var query = ""
    var selectedSegment: String?

    private let store: JSONFileStore<[Customer]>
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "PedidoFacil",
        category: "Customers"
    )

    init(store: JSONFileStore<[Customer]>? = nil) {
        self.store = store ?? JSONFileStore(fileURL: Self.defaultFileURL)
        do {
            customers = try self.store.load()?.value ?? []
        } catch {
            errorMessage = "Não foi possível carregar os clientes."
            logger.error("Failed to load customers: \(error.localizedDescription, privacy: .public)")
        }
    }

    var activeCustomers: [Customer] {
        customers
            .filter { !$0.isArchived }
            .filter(matchesFilters)
            .sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }

    var availableSegments: [String] {
        Array(Set(customers.filter { !$0.isArchived }.map(\.segment)))
            .sorted { $0.localizedCompare($1) == .orderedAscending }
    }

    @discardableResult
    func save(
        id: UUID? = nil,
        name: String,
        segment: String,
        tags: [String],
        city: String?,
        notes: String?,
        now: Date = Date()
    ) -> Customer? {
        let cleanName = name.trimmed
        guard !cleanName.isEmpty else {
            errorMessage = "Informe o nome do cliente."
            return nil
        }

        let normalizedTags = Dictionary(
            tags.map(\.trimmed)
                .filter { !$0.isEmpty }
                .map { ($0.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current), $0) },
            uniquingKeysWith: { first, _ in first }
        ).values.sorted { $0.localizedCompare($1) == .orderedAscending }

        let customer: Customer
        if let id, let index = customers.firstIndex(where: { $0.id == id }) {
            customers[index].name = cleanName
            customers[index].segment = segment.trimmed.nilIfEmpty ?? "Outros"
            customers[index].tags = normalizedTags
            customers[index].city = city?.trimmed.nilIfEmpty
            customers[index].notes = notes?.trimmed.nilIfEmpty
            customers[index].updatedAt = now
            customer = customers[index]
        } else {
            customer = Customer(
                name: cleanName,
                segment: segment.trimmed.nilIfEmpty ?? "Outros",
                tags: normalizedTags,
                city: city?.trimmed.nilIfEmpty,
                notes: notes?.trimmed.nilIfEmpty,
                createdAt: now,
                updatedAt: now
            )
            customers.append(customer)
        }

        return persist() ? customer : nil
    }

    func archive(id: UUID, now: Date = Date()) {
        guard let index = customers.firstIndex(where: { $0.id == id }) else { return }
        customers[index].archivedAt = now
        customers[index].updatedAt = now
        _ = persist()
    }

    func restore(id: UUID, now: Date = Date()) {
        guard let index = customers.firstIndex(where: { $0.id == id }) else { return }
        customers[index].archivedAt = nil
        customers[index].updatedAt = now
        _ = persist()
    }

    private func matchesFilters(_ customer: Customer) -> Bool {
        let matchesSegment = selectedSegment == nil || customer.segment == selectedSegment
        let cleanQuery = query.trimmed
        guard !cleanQuery.isEmpty else { return matchesSegment }
        let searchable = ([customer.name, customer.segment, customer.city ?? ""] + customer.tags)
            .joined(separator: " ")
        return matchesSegment && searchable.localizedCaseInsensitiveContains(cleanQuery)
    }

    private func persist() -> Bool {
        do {
            try store.save(customers)
            errorMessage = nil
            logger.debug("Customer collection persisted. Count: \(self.customers.count, privacy: .public)")
            return true
        } catch {
            errorMessage = "Não foi possível salvar os clientes."
            logger.error("Failed to persist customers: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    private static var defaultFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("customers.json")
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
