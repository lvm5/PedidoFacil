import Foundation

enum PriceListStatus: String, Codable, CaseIterable {
    case draft
    case reviewed
    case active
    case archived
}

enum PriceListItemIssue: String, Codable, Hashable, CaseIterable {
    case missingName
    case missingBrand
    case missingPrice
    case duplicate
    case ambiguousDescriptor
}

struct PriceListItem: Identifiable, Codable, Equatable {
    let id: UUID
    var sourceLineNumber: Int
    var originalLine: String
    var name: String
    var brand: String?
    var price: Decimal?
    var rawPriceText: String?
    var unit: String?
    var category: String?
    var note: String?
    var issues: Set<PriceListItemIssue>

    init(
        id: UUID = UUID(),
        sourceLineNumber: Int,
        originalLine: String,
        name: String,
        brand: String? = nil,
        price: Decimal? = nil,
        rawPriceText: String? = nil,
        unit: String? = nil,
        category: String? = nil,
        note: String? = nil,
        issues: Set<PriceListItemIssue> = []
    ) {
        self.id = id
        self.sourceLineNumber = sourceLineNumber
        self.originalLine = originalLine
        self.name = name
        self.brand = brand
        self.price = price
        self.rawPriceText = rawPriceText
        self.unit = unit
        self.category = category
        self.note = note
        self.issues = issues
    }

    var needsReview: Bool { !issues.isEmpty }
}

struct DailyPriceList: Identifiable, Codable, Equatable {
    let id: UUID
    var sourceText: String
    var createdAt: Date
    var updatedAt: Date
    var validUntil: Date?
    var status: PriceListStatus
    var items: [PriceListItem]

    init(
        id: UUID = UUID(),
        sourceText: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        validUntil: Date? = nil,
        status: PriceListStatus = .draft,
        items: [PriceListItem]
    ) {
        self.id = id
        self.sourceText = sourceText
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.validUntil = validUntil
        self.status = status
        self.items = items
    }

    var itemsNeedingReview: [PriceListItem] {
        items.filter(\.needsReview)
    }
}
