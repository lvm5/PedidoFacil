import SwiftUI

@MainActor
struct CustomerListView: View {
    @State private var store: CustomerStore
    @State private var showingNewCustomer = false
    @State private var customerToEdit: Customer?

    private let suggestedSegments: [String]

    init(
        store: CustomerStore,
        suggestedSegments: [String] = OperationalProfile().customerSegments
    ) {
        _store = State(initialValue: store)
        self.suggestedSegments = suggestedSegments
    }

    var body: some View {
        NavigationStack {
            List {
                filterSection
                customerSection
            }
            .navigationTitle("Clientes")
            .searchable(text: $store.query, prompt: "Nome, endereço, rota ou etiqueta")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Novo cliente", systemImage: "plus") {
                        showingNewCustomer = true
                    }
                }
            }
            .sheet(isPresented: $showingNewCustomer) {
                CustomerEditorView(
                    store: store,
                    suggestedSegments: suggestedSegments
                )
            }
            .sheet(item: $customerToEdit) { customer in
                CustomerEditorView(
                    store: store,
                    customer: customer,
                    suggestedSegments: suggestedSegments
                )
            }
        }
    }

    private var filterSection: some View {
        Section {
            Picker("Segmento", selection: $store.selectedSegment) {
                Text("Todos").tag(String?.none)
                ForEach(store.availableSegments, id: \.self) { segment in
                    Text(segment).tag(Optional(segment))
                }
            }
        }
    }

    @ViewBuilder
    private var customerSection: some View {
        Section {
            if store.activeCustomers.isEmpty {
                ContentUnavailableView(
                    store.customers.isEmpty ? "Nenhum cliente" : "Nenhum resultado",
                    systemImage: "person.2",
                    description: Text(store.customers.isEmpty
                        ? "Cadastre apenas os dados necessários para vender."
                        : "Tente outro nome, cidade, etiqueta ou segmento.")
                )
            } else {
                ForEach(store.activeCustomers) { customer in
                    Button {
                        customerToEdit = customer
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(customer.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text([customer.segment, customer.city].compactMap { $0 }.joined(separator: " · "))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if let address = customer.formattedAddress {
                                Label(address, systemImage: "mappin.and.ellipse")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            if let days = customer.deliveryDaysText {
                                Label(
                                    [customer.deliveryRoute, days].compactMap { $0 }.joined(separator: " · "),
                                    systemImage: "truck.box"
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                            if !customer.tags.isEmpty {
                                Text(customer.tags.joined(separator: " · "))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .swipeActions {
                        Button("Arquivar", systemImage: "archivebox", role: .destructive) {
                            store.archive(id: customer.id)
                        }
                    }
                }
            }
        } footer: {
            Text("Arquivar preserva o histórico e pode ser revertido em uma evolução futura.")
        }
    }
}

#Preview("Clientes") {
    CustomerListView(
        store: CustomerStore(
            store: JSONFileStore(
                fileURL: FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathComponent("customers.json")
            )
        )
    )
}
