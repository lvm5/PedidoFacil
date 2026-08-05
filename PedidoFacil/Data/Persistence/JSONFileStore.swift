import Foundation

struct PersistenceEnvelope<Value: Codable>: Codable {
    let schemaVersion: Int
    let savedAt: Date
    let payload: Value
}

enum JSONLoadSource: Equatable {
    case primaryEnvelope
    case primaryLegacy
    case backupEnvelope
    case backupLegacy

    var isLegacy: Bool {
        self == .primaryLegacy || self == .backupLegacy
    }

    var recoveredFromBackup: Bool {
        self == .backupEnvelope || self == .backupLegacy
    }
}

struct JSONLoadResult<Value> {
    let value: Value
    let source: JSONLoadSource
}

struct JSONFileStore<Value: Codable> {
    static var currentSchemaVersion: Int { 1 }

    let fileURL: URL

    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        fileURL: URL,
        fileManager: FileManager = .default,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.fileURL = fileURL
        self.fileManager = fileManager
        self.encoder = encoder
        self.decoder = decoder
    }

    var backupURL: URL {
        fileURL
            .deletingPathExtension()
            .appendingPathExtension("backup.json")
    }

    func load() throws -> JSONLoadResult<Value>? {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        do {
            return try decode(contentsOf: fileURL, envelope: .primaryEnvelope, legacy: .primaryLegacy)
        } catch let primaryError {
            guard fileManager.fileExists(atPath: backupURL.path) else {
                throw primaryError
            }

            return try decode(contentsOf: backupURL, envelope: .backupEnvelope, legacy: .backupLegacy)
        }
    }

    func save(_ value: Value, now: Date = Date()) throws {
        try fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try preserveValidPrimaryAsBackup()

        let envelope = PersistenceEnvelope(
            schemaVersion: Self.currentSchemaVersion,
            savedAt: now,
            payload: value
        )
        let data = try encoder.encode(envelope)
        try data.write(to: fileURL, options: [.atomic])
    }

    private func decode(
        contentsOf url: URL,
        envelope envelopeSource: JSONLoadSource,
        legacy legacySource: JSONLoadSource
    ) throws -> JSONLoadResult<Value> {
        let data = try Data(contentsOf: url)

        if let envelope = try? decoder.decode(PersistenceEnvelope<Value>.self, from: data) {
            guard envelope.schemaVersion <= Self.currentSchemaVersion else {
                throw CocoaError(.fileReadCorruptFile)
            }
            return JSONLoadResult(value: envelope.payload, source: envelopeSource)
        }

        return JSONLoadResult(
            value: try decoder.decode(Value.self, from: data),
            source: legacySource
        )
    }

    private func preserveValidPrimaryAsBackup() throws {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return
        }

        let primaryData = try Data(contentsOf: fileURL)
        guard (try? decoder.decode(PersistenceEnvelope<Value>.self, from: primaryData)) != nil
                || (try? decoder.decode(Value.self, from: primaryData)) != nil else {
            return
        }

        try primaryData.write(to: backupURL, options: [.atomic])
    }
}
