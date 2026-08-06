import Foundation

struct LocalTime: Codable, Equatable, Hashable {
    let hour: Int
    let minute: Int

    init(hour: Int, minute: Int) {
        precondition((0...23).contains(hour), "Hour must be between 0 and 23")
        precondition((0...59).contains(minute), "Minute must be between 0 and 59")
        self.hour = hour
        self.minute = minute
    }

    func date(on day: Date, calendar: Calendar = .current) -> Date? {
        calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day)
    }
}

struct OperationalProfile: Codable, Equatable {
    static let defaultCustomerSegments = [
        "Supermercado",
        "Açougue",
        "Restaurante",
        "Lanchonete",
        "Padaria",
        "Pizzaria",
        "Instituição",
        "Outros"
    ]

    var operationName: String
    var submissionStartTime: LocalTime
    var submissionDeadline: LocalTime
    var reminderOffsetsInMinutes: [Int]
    var customerSegments: [String]
    var messageSignature: String

    init(
        operationName: String = "",
        submissionStartTime: LocalTime = LocalTime(hour: 8, minute: 0),
        submissionDeadline: LocalTime = LocalTime(hour: 16, minute: 30),
        reminderOffsetsInMinutes: [Int] = [60, 30, 10],
        customerSegments: [String] = Self.defaultCustomerSegments,
        messageSignature: String = ""
    ) {
        self.operationName = operationName
        self.submissionStartTime = submissionStartTime
        self.submissionDeadline = submissionDeadline
        self.reminderOffsetsInMinutes = reminderOffsetsInMinutes
            .filter { $0 > 0 }
            .sorted(by: >)
        self.customerSegments = customerSegments
        self.messageSignature = messageSignature
    }

    private enum CodingKeys: String, CodingKey {
        case operationName
        case submissionStartTime
        case submissionDeadline
        case reminderOffsetsInMinutes
        case customerSegments
        case messageSignature
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        operationName = try values.decodeIfPresent(String.self, forKey: .operationName) ?? ""
        submissionStartTime = try values.decodeIfPresent(LocalTime.self, forKey: .submissionStartTime)
            ?? LocalTime(hour: 8, minute: 0)
        submissionDeadline = try values.decodeIfPresent(LocalTime.self, forKey: .submissionDeadline)
            ?? LocalTime(hour: 16, minute: 30)
        reminderOffsetsInMinutes = try values.decodeIfPresent([Int].self, forKey: .reminderOffsetsInMinutes)
            ?? [60, 30, 10]
        customerSegments = try values.decodeIfPresent([String].self, forKey: .customerSegments)
            ?? Self.defaultCustomerSegments
        messageSignature = try values.decodeIfPresent(String.self, forKey: .messageSignature) ?? ""
    }
}
