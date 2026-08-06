import SwiftUI

struct CustomerEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let store: CustomerStore
    let customer: Customer?
    let suggestedSegments: [String]

    @State private var name: String
    @State private var segment: String
    @State private var city: String
    @State private var state: String
    @State private var postalCode: String
    @State private var street: String
    @State private var addressNumber: String
    @State private var neighborhood: String
    @State private var addressComplement: String
    @State private var deliveryRoute: String
    @State private var deliveryDays: Set<DeliveryWeekday>
    @State private var tagsText: String
    @State private var notes: String

    init(store: CustomerStore, customer: Customer? = nil, suggestedSegments: [String]) {
        self.store = store
        self.customer = customer
        self.suggestedSegments = suggestedSegments
        _name = State(initialValue: customer?.name ?? "")
        _segment = State(initialValue: customer?.segment ?? suggestedSegments.first ?? "Outros")
        _city = State(initialValue: customer?.city ?? "")
        _state = State(initialValue: customer?.state ?? "SP")
        _postalCode = State(initialValue: customer?.postalCode ?? "")
        _street = State(initialValue: customer?.street ?? "")
        _addressNumber = State(initialValue: customer?.addressNumber ?? "")
        _neighborhood = State(initialValue: customer?.neighborhood ?? "")
        _addressComplement = State(initialValue: customer?.addressComplement ?? "")
        _deliveryRoute = State(initialValue: customer?.deliveryRoute ?? "")
        _deliveryDays = State(
            initialValue: Set(
                customer?.deliveryDays
                    ?? DeliveryRouteSuggestion.days(for: customer?.city, state: customer?.state)
            )
        )
        _tagsText = State(initialValue: customer?.tags.joined(separator: ", ") ?? "")
        _notes = State(initialValue: customer?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Cliente") {
                    TextField("Nome", text: $name)
                        .textContentType(.organizationName)
                }

                Section("Endereço") {
                    TextField("Rua ou avenida", text: $street)
                        .textContentType(.streetAddressLine1)
                    HStack {
                        TextField("Número", text: $addressNumber)
                        TextField("Complemento", text: $addressComplement)
                    }
                    TextField("Bairro", text: $neighborhood)
                        .textContentType(.sublocality)
                    HStack {
                        TextField("Cidade", text: $city)
                        .textContentType(.addressCity)
                        TextField("UF", text: $state)
                            .textInputAutocapitalization(.characters)
                            .frame(maxWidth: 72)
                    }
                    TextField("CEP", text: $postalCode)
                        .textContentType(.postalCode)
                        .keyboardType(.numbersAndPunctuation)
                }

                Section("Entregas") {
                    TextField("Nome da rota (opcional)", text: $deliveryRoute)
                    ForEach(DeliveryWeekday.allCases, id: \.self) { day in
                        Toggle(day.shortName, isOn: dayBinding(day))
                    }
                    if !suggestedDeliveryDays.isEmpty {
                        Button("Usar dias sugeridos para \(city)") {
                            deliveryDays = Set(suggestedDeliveryDays)
                        }
                    }
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
            .onChange(of: city) { _, _ in applySuggestionWhenEmpty() }
            .onChange(of: state) { _, _ in applySuggestionWhenEmpty() }
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
            state: state,
            postalCode: postalCode,
            street: street,
            addressNumber: addressNumber,
            neighborhood: neighborhood,
            addressComplement: addressComplement,
            deliveryRoute: deliveryRoute,
            deliveryDays: deliveryDays.sorted(),
            notes: notes
        ) != nil {
            dismiss()
        }
    }

    private var suggestedDeliveryDays: [DeliveryWeekday] {
        DeliveryRouteSuggestion.days(for: city, state: state)
    }

    private func dayBinding(_ day: DeliveryWeekday) -> Binding<Bool> {
        Binding(
            get: { deliveryDays.contains(day) },
            set: { enabled in
                if enabled { deliveryDays.insert(day) } else { deliveryDays.remove(day) }
            }
        )
    }

    private func applySuggestionWhenEmpty() {
        guard deliveryDays.isEmpty else { return }
        deliveryDays = Set(suggestedDeliveryDays)
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
