import XCTest
@testable import PedidoFacil

@MainActor
final class OperationalSettingsTests: XCTestCase {
    func testDefaultProfileUsesSuggestedDeadlineWithoutHardcodingConsumers() {
        let profile = OperationalProfile()

        XCTAssertEqual(profile.submissionDeadline, LocalTime(hour: 16, minute: 30))
        XCTAssertEqual(profile.reminderOffsetsInMinutes, [60, 30, 10])
    }

    func testCustomDeadlinePersistsAndProducesDateInProvidedCalendar() throws {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directoryURL) }
        let store = JSONFileStore<OperationalProfile>(
            fileURL: directoryURL.appendingPathComponent("profile.json")
        )
        let settings = OperationalSettings(store: store)
        let profile = OperationalProfile(
            operationName: "Minha operação",
            submissionDeadline: LocalTime(hour: 18, minute: 15),
            reminderOffsetsInMinutes: [10, 60, -5, 30],
            customerSegments: ["Loja", "Restaurante"],
            messageSignature: "Pedidos até 18h15"
        )
        settings.update(profile)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "America/Sao_Paulo"))
        let day = Date(timeIntervalSince1970: 1_785_962_400)

        let restored = OperationalSettings(store: store)
        let deadline = try XCTUnwrap(restored.deadline(on: day, calendar: calendar))
        let components = calendar.dateComponents([.hour, .minute], from: deadline)

        XCTAssertEqual(restored.profile, profile)
        XCTAssertEqual(restored.profile.reminderOffsetsInMinutes, [60, 30, 10])
        XCTAssertEqual(components.hour, 18)
        XCTAssertEqual(components.minute, 15)
    }
}
