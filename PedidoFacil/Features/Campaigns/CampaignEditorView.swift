import SwiftUI

struct CampaignEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let store: CampaignStore
    let priceLists: [DailyPriceList]
    let customers: [Customer]

    @State private var title = "Ofertas do dia"
    @State private var selectedListID: UUID?
    @State private var selectedItemIDs: Set<UUID> = []
    @State private var priorityItemIDs: Set<UUID> = []
    @State private var selectedCustomerIDs: Set<UUID> = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Campanha") {
                    TextField("Título", text: $title)
                    Picker("Lista revisada", selection: $selectedListID) {
                        Text("Selecione").tag(UUID?.none)
                        ForEach(usableLists) { list in
                            Text(list.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .tag(Optional(list.id))
                        }
                    }
                }

                if let selectedList {
                    Section("Produtos") {
                        ForEach(selectedList.items) { item in
                            Toggle(isOn: membershipBinding(item.id, in: $selectedItemIDs)) {
                                VStack(alignment: .leading) {
                                    Text([item.name, item.brand].compactMap { $0 }.joined(separator: " — "))
                                    if let price = item.price {
                                        Text(price.formatted(.currency(code: Locale.current.currency?.identifier ?? "BRL")))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            if selectedItemIDs.contains(item.id) {
                                Toggle("Destacar na lista curta", isOn: membershipBinding(item.id, in: $priorityItemIDs))
                                    .font(.caption)
                            }
                        }
                    }
                }

                Section("Clientes") {
                    if customers.isEmpty {
                        Text("Cadastre clientes para registrar os envios.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(customers) { customer in
                            Toggle(
                                customer.name,
                                isOn: membershipBinding(customer.id, in: $selectedCustomerIDs)
                            )
                        }
                    }
                }

                if let error = store.errorMessage {
                    Section { Label(error, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange) }
                }
            }
            .navigationTitle("Nova oferta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Criar") { create() }
                        .disabled(selectedList == nil || selectedItemIDs.isEmpty || title.trimmed.isEmpty)
                }
            }
            .onChange(of: selectedListID) {
                selectedItemIDs.removeAll()
                priorityItemIDs.removeAll()
            }
        }
    }

    private var usableLists: [DailyPriceList] {
        priceLists.filter { $0.status == .reviewed || $0.status == .active }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    private var selectedList: DailyPriceList? {
        usableLists.first { $0.id == selectedListID }
    }

    private func membershipBinding(_ id: UUID, in selection: Binding<Set<UUID>>) -> Binding<Bool> {
        Binding(
            get: { selection.wrappedValue.contains(id) },
            set: { included in
                if included { selection.wrappedValue.insert(id) }
                else { selection.wrappedValue.remove(id) }
            }
        )
    }

    private func create() {
        guard let selectedList else { return }
        if store.create(
            title: title,
            priceList: selectedList,
            selectedItemIDs: selectedItemIDs,
            priorityItemIDs: priorityItemIDs,
            customerIDs: Array(selectedCustomerIDs)
        ) != nil {
            dismiss()
        }
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
