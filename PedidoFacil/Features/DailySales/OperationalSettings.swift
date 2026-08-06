import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class OperationalSettings {
    private(set) var profile: OperationalProfile
    private(set) var persistenceErrorMessage: String?

    private let store: JSONFileStore<OperationalProfile>
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "PedidoFacil",
        category: "OperationalSettings"
    )

    init(store: JSONFileStore<OperationalProfile>? = nil) {
        self.store = store ?? JSONFileStore(fileURL: Self.defaultFileURL)

        do {
            profile = try self.store.load()?.value ?? OperationalProfile()
        } catch {
            profile = OperationalProfile()
            persistenceErrorMessage = "Não foi possível carregar os ajustes. Os padrões foram mantidos."
            logger.error("Failed to load operational settings: \(error.localizedDescription, privacy: .public)")
        }
    }

    func update(_ newProfile: OperationalProfile) {
        do {
            try store.save(newProfile)
            profile = newProfile
            persistenceErrorMessage = nil
            logger.info("Operational settings saved.")
        } catch {
            persistenceErrorMessage = "Não foi possível salvar os ajustes. Tente novamente."
            logger.error("Failed to save operational settings: \(error.localizedDescription, privacy: .public)")
        }
    }

    func deadline(on day: Date, calendar: Calendar = .current) -> Date? {
        profile.submissionDeadline.date(on: day, calendar: calendar)
    }

    func startTime(on day: Date, calendar: Calendar = .current) -> Date? {
        profile.submissionStartTime.date(on: day, calendar: calendar)
    }

    private static var defaultFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("operationalProfile.json")
    }
}
