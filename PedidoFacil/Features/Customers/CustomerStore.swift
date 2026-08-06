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
        state: String? = nil,
        postalCode: String? = nil,
        street: String? = nil,
        addressNumber: String? = nil,
        neighborhood: String? = nil,
        addressComplement: String? = nil,
        deliveryRoute: String? = nil,
        deliveryDays: [DeliveryWeekday]? = nil,
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
        let cleanCity = city?.trimmed.nilIfEmpty
        let cleanState = state?.trimmed.nilIfEmpty?.uppercased()
        let resolvedDeliveryDays = deliveryDays?.sorted() ?? DeliveryRouteSuggestion.days(
            for: cleanCity,
            state: cleanState
        )

        var nextCustomers = customers
        let customer: Customer
        if let id, let index = nextCustomers.firstIndex(where: { $0.id == id }) {
            nextCustomers[index].name = cleanName
            nextCustomers[index].segment = segment.trimmed.nilIfEmpty ?? "Outros"
            nextCustomers[index].tags = normalizedTags
            nextCustomers[index].city = cleanCity
            nextCustomers[index].state = cleanState
            nextCustomers[index].postalCode = postalCode?.trimmed.nilIfEmpty
            nextCustomers[index].street = street?.trimmed.nilIfEmpty
            nextCustomers[index].addressNumber = addressNumber?.trimmed.nilIfEmpty
            nextCustomers[index].neighborhood = neighborhood?.trimmed.nilIfEmpty
            nextCustomers[index].addressComplement = addressComplement?.trimmed.nilIfEmpty
            nextCustomers[index].deliveryRoute = deliveryRoute?.trimmed.nilIfEmpty
            nextCustomers[index].deliveryDays = resolvedDeliveryDays.nilIfEmpty
            nextCustomers[index].notes = notes?.trimmed.nilIfEmpty
            nextCustomers[index].updatedAt = now
            customer = nextCustomers[index]
        } else {
            customer = Customer(
                name: cleanName,
                segment: segment.trimmed.nilIfEmpty ?? "Outros",
                tags: normalizedTags,
                city: cleanCity,
                state: cleanState,
                postalCode: postalCode?.trimmed.nilIfEmpty,
                street: street?.trimmed.nilIfEmpty,
                addressNumber: addressNumber?.trimmed.nilIfEmpty,
                neighborhood: neighborhood?.trimmed.nilIfEmpty,
                addressComplement: addressComplement?.trimmed.nilIfEmpty,
                deliveryRoute: deliveryRoute?.trimmed.nilIfEmpty,
                deliveryDays: resolvedDeliveryDays.nilIfEmpty,
                notes: notes?.trimmed.nilIfEmpty,
                createdAt: now,
                updatedAt: now
            )
            nextCustomers.append(customer)
        }

        return persist(nextCustomers) ? customer : nil
    }

    func archive(id: UUID, now: Date = Date()) {
        var nextCustomers = customers
        guard let index = nextCustomers.firstIndex(where: { $0.id == id }) else { return }
        nextCustomers[index].archivedAt = now
        nextCustomers[index].updatedAt = now
        _ = persist(nextCustomers)
    }

    func restore(id: UUID, now: Date = Date()) {
        var nextCustomers = customers
        guard let index = nextCustomers.firstIndex(where: { $0.id == id }) else { return }
        nextCustomers[index].archivedAt = nil
        nextCustomers[index].updatedAt = now
        _ = persist(nextCustomers)
    }

    private func matchesFilters(_ customer: Customer) -> Bool {
        let matchesSegment = selectedSegment == nil || customer.segment == selectedSegment
        let cleanQuery = query.trimmed
        guard !cleanQuery.isEmpty else { return matchesSegment }
        let searchable = ([
            customer.name,
            customer.segment,
            customer.city ?? "",
            customer.state ?? "",
            customer.street ?? "",
            customer.neighborhood ?? "",
            customer.deliveryRoute ?? ""
        ] + customer.tags)
            .joined(separator: " ")
        return matchesSegment && searchable.localizedCaseInsensitiveContains(cleanQuery)
    }

    private func persist(_ nextCustomers: [Customer]) -> Bool {
        do {
            try store.save(nextCustomers)
            customers = nextCustomers
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

private extension Array {
    var nilIfEmpty: Self? { isEmpty ? nil : self }
}
