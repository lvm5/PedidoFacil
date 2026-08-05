import Foundation

struct Customer: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var segment: String
    var tags: [String]
    var city: String?
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
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.archivedAt = archivedAt
    }

    var isArchived: Bool { archivedAt != nil }
}
