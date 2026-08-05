import Foundation

enum CustomerInteractionStatus: String, Codable, CaseIterable {
    case notContacted
    case sent
    case viewed
    case interested
    case noResponse
    case ordered
}

struct CampaignOfferItem: Identifiable, Codable, Equatable {
    let id: UUID
    let sourceItemID: UUID?
    var name: String
    var brand: String
    var price: Decimal
    var unit: String?
    var category: String
    var isPriority: Bool

    init(
        id: UUID = UUID(),
        sourceItemID: UUID? = nil,
        name: String,
        brand: String,
        price: Decimal,
        unit: String? = nil,
        category: String = "Outros",
        isPriority: Bool = false
    ) {
        self.id = id
        self.sourceItemID = sourceItemID
        self.name = name
        self.brand = brand
        self.price = price
        self.unit = unit
        self.category = category
        self.isPriority = isPriority
    }
}

struct CustomerInteraction: Identifiable, Codable, Equatable {
    let id: UUID
    let customerID: UUID
    var status: CustomerInteractionStatus
    let createdAt: Date
    var updatedAt: Date
    var note: String?

    init(
        id: UUID = UUID(),
        customerID: UUID,
        status: CustomerInteractionStatus = .notContacted,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        note: String? = nil
    ) {
        self.id = id
        self.customerID = customerID
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.note = note
    }
}

struct SalesCampaign: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var priceListID: UUID?
    var items: [CampaignOfferItem]
    var customerIDs: [UUID]
    var interactions: [CustomerInteraction]
    let createdAt: Date
    var updatedAt: Date
    var archivedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        priceListID: UUID? = nil,
        items: [CampaignOfferItem],
        customerIDs: [UUID] = [],
        interactions: [CustomerInteraction] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        archivedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.priceListID = priceListID
        self.items = items
        self.customerIDs = customerIDs
        self.interactions = interactions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.archivedAt = archivedAt
    }

    var isArchived: Bool { archivedAt != nil }

    func interactionStatus(for customerID: UUID) -> CustomerInteractionStatus {
        interactions.last(where: { $0.customerID == customerID })?.status ?? .notContacted
    }
}
