import Foundation

enum DeliveryWeekday: Int, Codable, CaseIterable, Comparable, Hashable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    var shortName: String {
        switch self {
        case .sunday: "Dom"
        case .monday: "Seg"
        case .tuesday: "Ter"
        case .wednesday: "Qua"
        case .thursday: "Qui"
        case .friday: "Sex"
        case .saturday: "Sáb"
        }
    }

    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
}

struct Customer: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var segment: String
    var tags: [String]
    var city: String?
    var state: String?
    var postalCode: String?
    var street: String?
    var addressNumber: String?
    var neighborhood: String?
    var addressComplement: String?
    var deliveryRoute: String?
    var deliveryDays: [DeliveryWeekday]?
    var notes: String?
    let createdAt: Date
    var updatedAt: Date
    var archivedAt: Date?

    init(
        id: UUID = UUID(),
        name: String,
        segment: String = "Outros",
        tags: [String] = [],
        city: String? = nil,
        state: String? = nil,
        postalCode: String? = nil,
        street: String? = nil,
        addressNumber: String? = nil,
        neighborhood: String? = nil,
        addressComplement: String? = nil,
        deliveryRoute: String? = nil,
        deliveryDays: [DeliveryWeekday]? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        archivedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.segment = segment
        self.tags = tags
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.street = street
        self.addressNumber = addressNumber
        self.neighborhood = neighborhood
        self.addressComplement = addressComplement
        self.deliveryRoute = deliveryRoute
        self.deliveryDays = deliveryDays
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.archivedAt = archivedAt
    }

    var isArchived: Bool { archivedAt != nil }

    var deliveryDaysText: String? {
        guard let deliveryDays, !deliveryDays.isEmpty else { return nil }
        return deliveryDays.sorted().map(\.shortName).joined(separator: ", ")
    }

    var formattedAddress: String? {
        let streetLine = [street, addressNumber].compactMap { $0?.nilIfBlank }.joined(separator: ", ")
        let cityLine = [city, state].compactMap { $0?.nilIfBlank }.joined(separator: " - ")
        let lines = [streetLine.nilIfBlank, neighborhood?.nilIfBlank, cityLine.nilIfBlank, postalCode?.nilIfBlank]
            .compactMap { $0 }
        return lines.isEmpty ? nil : lines.joined(separator: " · ")
    }
}

enum DeliveryRouteSuggestion {
    static func days(for city: String?, state: String?) -> [DeliveryWeekday] {
        guard state?.normalizedAddressValue == nil || state?.normalizedAddressValue == "sp" else { return [] }
        return switch city?.normalizedAddressValue {
        case "botucatu", "sao manuel": [.tuesday, .wednesday, .thursday]
        case "areiopolis", "itatinga": [.wednesday]
        default: []
        }
    }
}

private extension String {
    var nilIfBlank: String? {
        let clean = trimmingCharacters(in: .whitespacesAndNewlines)
        return clean.isEmpty ? nil : clean
    }

    var normalizedAddressValue: String {
        folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "pt_BR"))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
