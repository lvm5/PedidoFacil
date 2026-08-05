import SwiftUI

struct CustomerEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let store: CustomerStore
    let customer: Customer?
    let suggestedSegments: [String]

    @State private var name: String
    @State private var segment: String
    @State private var city: String
    @State private var tagsText: String
    @State private var notes: String

    init(store: CustomerStore, customer: Customer? = nil, suggestedSegments: [String]) {
        self.store = store
        self.customer = customer
        self.suggestedSegments = suggestedSegments
        _name = State(initialValue: customer?.name ?? "")
        _segment = State(initialValue: customer?.segment ?? suggestedSegments.first ?? "Outros")
        _city = State(initialValue: customer?.city ?? "")
        _tagsText = State(initialValue: customer?.tags.joined(separator: ", ") ?? "")
        _notes = State(initialValue: customer?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Cliente") {
                    TextField("Nome", text: $name)
                        .textContentType(.organizationName)
                    TextField("Cidade (opcional)", text: $city)
                        .textContentType(.addressCity)
                }

                Section("Segmento") {
                    Picker("Segmento", selection: $segment) {
                        ForEach(segments, id: \.self) { Text($0).tag($0) }
                    }
                    TextField("Ou digite outro", text: $segment)
                }

                Section("Organização") {
                    TextField("Etiquetas separadas por vírgula", text: $tagsText)
                    TextField("Observações", text: $notes, axis: .vertical)
                        .lineLimit(2...5)
                }

                if let error = store.errorMessage {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }
                }
            }
            .navigationTitle(customer == nil ? "Novo cliente" : "Editar cliente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var segments: [String] {
        Array(Set(suggestedSegments + store.availableSegments + [segment, "Outros"]))
            .filter { !$0.isEmpty }
            .sorted { $0.localizedCompare($1) == .orderedAscending }
    }

    private func save() {
        let tags = tagsText.split(separator: ",").map(String.init)
        if store.save(
            id: customer?.id,
            name: name,
            segment: segment,
            tags: tags,
            city: city,
            notes: notes
        ) != nil {
            dismiss()
        }
    }
}

#Preview("Novo cliente") {
    CustomerEditorView(
        store: CustomerStore(
            store: JSONFileStore(
                fileURL: FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathComponent("customers.json")
            )
        ),
        suggestedSegments: OperationalProfile().customerSegments
    )
}
