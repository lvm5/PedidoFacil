import SwiftUI

@MainActor
struct CampaignListView: View {
    @State private var campaignStore: CampaignStore
    @State private var customerStore: CustomerStore
    @State private var priceListStore: PriceListImportViewModel
    @State private var settings: OperationalSettings
    @State private var showingEditor = false

    init(
        campaignStore: CampaignStore,
        customerStore: CustomerStore,
        priceListStore: PriceListImportViewModel,
        settings: OperationalSettings
    ) {
        _campaignStore = State(initialValue: campaignStore)
        _customerStore = State(initialValue: customerStore)
        _priceListStore = State(initialValue: priceListStore)
        _settings = State(initialValue: settings)
    }

    var body: some View {
        List {
            if campaignStore.activeCampaigns.isEmpty {
                ContentUnavailableView(
                    "Nenhuma oferta",
                    systemImage: "megaphone",
                    description: Text("Crie uma oferta a partir de uma lista revisada.")
                )
            } else {
                ForEach(campaignStore.activeCampaigns) { campaign in
                    NavigationLink {
                        CampaignDetailView(
                            campaignID: campaign.id,
                            store: campaignStore,
                            customers: customerStore.customers,
                            settings: settings
                        )
                    } label: {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(campaign.title).font(.headline)
                            Text("\(campaign.items.count) produtos · \(campaign.customerIDs.count) clientes")
                                .foregroundStyle(.secondary)
                            Text(campaign.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions {
                        Button("Arquivar", systemImage: "archivebox", role: .destructive) {
                            campaignStore.archive(id: campaign.id)
                        }
                    }
                }
            }
        }
        .navigationTitle("Ofertas")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Nova oferta", systemImage: "plus") { showingEditor = true }
            }
        }
        .sheet(isPresented: $showingEditor) {
            CampaignEditorView(
                store: campaignStore,
                priceLists: priceListStore.savedLists,
                customers: customerStore.activeCustomers
            )
        }
    }
}

private struct CampaignDetailView: View {
    let campaignID: UUID
    let store: CampaignStore
    let customers: [Customer]
    let settings: OperationalSettings

    private var campaign: SalesCampaign? {
        store.campaigns.first { $0.id == campaignID }
    }

    var body: some View {
        List {
            if let campaign {
                Section("Compartilhar") {
                    ShareLink(item: message(campaign, compact: true)) {
                        Label("Lista curta", systemImage: "square.and.arrow.up")
                    }
                    ShareLink(item: message(campaign, compact: false)) {
                        Label("Lista completa", systemImage: "list.bullet")
                    }
                }

                Section("Clientes") {
                    if campaign.customerIDs.isEmpty {
                        Text("Nenhum cliente selecionado.").foregroundStyle(.secondary)
                    }
                    ForEach(campaign.customerIDs, id: \.self) { customerID in
                        if let customer = customers.first(where: { $0.id == customerID }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(customer.name)
                                    Text(statusLabel(campaign.interactionStatus(for: customerID)))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Menu("Atualizar") {
                                    ForEach(CustomerInteractionStatus.allCases, id: \.self) { status in
                                        Button(statusLabel(status)) {
                                            store.updateInteraction(
                                                campaignID: campaignID,
                                                customerID: customerID,
                                                status: status
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(campaign?.title ?? "Oferta")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func message(_ campaign: SalesCampaign, compact: Bool) -> String {
        OfferMessageGenerator().generate(
            campaign: campaign,
            deadline: settings.profile.submissionDeadline,
            signature: settings.profile.messageSignature,
            compact: compact
        )
    }

    private func statusLabel(_ status: CustomerInteractionStatus) -> String {
        switch status {
        case .notContacted: "Não contatado"
        case .sent: "Enviado"
        case .viewed: "Visualizado"
        case .interested: "Interessado"
        case .noResponse: "Sem retorno"
        case .ordered: "Pedido realizado"
        }
    }
}
