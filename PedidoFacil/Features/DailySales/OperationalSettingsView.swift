import SwiftUI

struct OperationalSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let settings: OperationalSettings

    @State private var operationName: String
    @State private var startTime: Date
    @State private var deadline: Date
    @State private var messageSignature: String

    init(settings: OperationalSettings) {
        self.settings = settings
        _operationName = State(initialValue: settings.profile.operationName)
        _messageSignature = State(initialValue: settings.profile.messageSignature)
        let time = settings.profile.submissionDeadline
        let start = settings.profile.submissionStartTime
        _startTime = State(
            initialValue: Calendar.current.date(
                bySettingHour: start.hour,
                minute: start.minute,
                second: 0,
                of: Date()
            ) ?? Date()
        )
        _deadline = State(
            initialValue: Calendar.current.date(
                bySettingHour: time.hour,
                minute: time.minute,
                second: 0,
                of: Date()
            ) ?? Date()
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Operação") {
                    TextField("Nome opcional", text: $operationName)
                    DatePicker(
                        "Horário inicial",
                        selection: $startTime,
                        displayedComponents: .hourAndMinute
                    )
                    DatePicker(
                        "Horário final",
                        selection: $deadline,
                        displayedComponents: .hourAndMinute
                    )
                }

                Section("Mensagens") {
                    TextField("Assinatura opcional", text: $messageSignature, axis: .vertical)
                }

                Section {
                    Text("Os avisos serão calculados 60, 30 e 10 minutos antes do horário escolhido.")
                        .foregroundStyle(.secondary)
                }

                if !isTimeRangeValid {
                    Section {
                        Label(
                            "O horário inicial deve ser anterior ao horário final.",
                            systemImage: "exclamationmark.triangle.fill"
                        )
                        .foregroundStyle(.orange)
                    }
                }

                if let error = settings.persistenceErrorMessage {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }
                }
            }
            .navigationTitle("Ajustes do dia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { save() }
                        .disabled(!isTimeRangeValid)
                }
            }
        }
    }

    private func save() {
        let startComponents = Calendar.current.dateComponents([.hour, .minute], from: startTime)
        let components = Calendar.current.dateComponents([.hour, .minute], from: deadline)
        guard let startHour = startComponents.hour,
              let startMinute = startComponents.minute,
              let hour = components.hour,
              let minute = components.minute else { return }
        var profile = settings.profile
        profile.operationName = operationName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.submissionStartTime = LocalTime(hour: startHour, minute: startMinute)
        profile.submissionDeadline = LocalTime(hour: hour, minute: minute)
        profile.messageSignature = messageSignature.trimmingCharacters(in: .whitespacesAndNewlines)
        settings.update(profile)
        if settings.persistenceErrorMessage == nil { dismiss() }
    }

    private var isTimeRangeValid: Bool {
        let start = Calendar.current.dateComponents([.hour, .minute], from: startTime)
        let end = Calendar.current.dateComponents([.hour, .minute], from: deadline)
        guard let startHour = start.hour,
              let startMinute = start.minute,
              let endHour = end.hour,
              let endMinute = end.minute else { return false }
        return startHour * 60 + startMinute < endHour * 60 + endMinute
    }
}

#Preview("Ajustes operacionais") {
    OperationalSettingsView(
        settings: OperationalSettings(
            store: JSONFileStore(
                fileURL: FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathComponent("profile.json")
            )
        )
    )
}
