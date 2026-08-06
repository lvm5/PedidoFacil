import SwiftUI

struct DailySalesView: View {
    @State private var settings: OperationalSettings
    @State private var fastOrderViewModel: FastOrderViewModel
    @State private var priceListViewModel: PriceListImportViewModel
    @State private var customerStore: CustomerStore
    @State private var campaignStore: CampaignStore
    @State private var showingSettings = false

    private let products: [Product]

    init(products: [Product]) {
        self.products = products
        let customers = CustomerStore()
        _settings = State(initialValue: OperationalSettings())
        _customerStore = State(initialValue: customers)
        _campaignStore = State(initialValue: CampaignStore())
        _priceListViewModel = State(
            initialValue: PriceListImportViewModel(
                knownBrands: Array(Set(products.compactMap(\.brand))),
                knownCategories: Array(Set(products.map(\.category)))
            )
        )
        _fastOrderViewModel = State(
            initialValue: FastOrderViewModel(
                products: products,
                customers: customers.activeCustomers
            )
        )
    }

    var body: some View {
        NavigationStack {
            List {
                deadlineSection
                activeListSection
                actionsSection
                pendingSection
                historySection
                legacySection
            }
            .navigationTitle("Central do Dia")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Ajustes", systemImage: "gearshape") {
                        showingSettings = true
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                OperationalSettingsView(settings: settings)
            }
        }
    }

    private var historySection: some View {
        Section {
            NavigationLink {
                SalesOrderHistoryView(viewModel: fastOrderViewModel)
            } label: {
                Label("Histórico comercial", systemImage: "clock.arrow.circlepath")
            }
        }
    }

    private var activeListSection: some View {
        Section("Lista ativa") {
            if let list = activePriceList {
                LabeledContent("Produtos revisados", value: "\(list.items.count)")
                LabeledContent(
                    "Atualizada",
                    value: list.updatedAt.formatted(date: .abbreviated, time: .shortened)
                )
            } else {
                Text("Nenhuma lista revisada.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var deadlineSection: some View {
        Section {
            TimelineView(.periodic(from: .now, by: 60)) { context in
                VStack(alignment: .leading, spacing: 6) {
                    LabeledContent(
                        "Horário de pedidos",
                        value: operatingHoursText(on: context.date)
                    )
                    Text(remainingText(at: context.date))
                        .font(.headline)
                        .foregroundStyle(deadlineColor(at: context.date))
                }
                .accessibilityElement(children: .combine)
            }
        } header: {
            Text(settings.profile.operationName.nilIfBlank ?? "Hoje")
        }
    }

    private var actionsSection: some View {
        Section("Ações principais") {
            NavigationLink {
                PriceListImportView(
                    viewModel: priceListViewModel
                )
            } label: {
                Label("Importar lista", systemImage: "doc.on.clipboard")
            }

            NavigationLink {
                FastOrderView(
                    viewModel: fastOrderViewModel,
                    customerProvider: { CustomerStore().activeCustomers }
                )
            } label: {
                Label("Criar pedido", systemImage: "cart.badge.plus")
            }

            NavigationLink {
                CampaignListView(
                    campaignStore: campaignStore,
                    customerStore: customerStore,
                    priceListStore: priceListViewModel,
                    settings: settings
                )
            } label: {
                Label("Enviar ofertas", systemImage: "megaphone")
            }

            NavigationLink {
                SalesOrderHistoryView(viewModel: fastOrderViewModel)
            } label: {
                Label("Resolver pendências", systemImage: "checklist")
            }
        }
    }

    private var pendingSection: some View {
        Section("Pendências") {
            metricRow(
                "Clientes não contatados",
                count: interactionCount(.notContacted),
                systemImage: "person.crop.circle.badge.questionmark"
            )
            metricRow(
                "Clientes interessados",
                count: interactionCount(.interested),
                systemImage: "person.crop.circle.badge.checkmark"
            )
            metricRow(
                "Rascunhos",
                count: count(.draft),
                systemImage: "square.and.pencil"
            )
            metricRow(
                "Aguardando ajuste",
                count: count(.awaitingDiscountApproval),
                systemImage: "percent"
            )
            metricRow(
                "Prontos para lançamento",
                count: count(.readyToSubmit),
                systemImage: "checkmark.circle"
            )
            metricRow(
                "Concluídos",
                count: count(.completed),
                systemImage: "checkmark.seal"
            )
        }
    }

    private var activePriceList: DailyPriceList? {
        priceListViewModel.savedLists
            .filter { $0.status == .reviewed || $0.status == .active }
            .max { $0.updatedAt < $1.updatedAt }
    }

    private func interactionCount(_ status: CustomerInteractionStatus) -> Int {
        campaignStore.activeCampaigns.reduce(0) { total, campaign in
            total + campaign.customerIDs.filter {
                campaign.interactionStatus(for: $0) == status
            }.count
        }
    }

    private var legacySection: some View {
        Section {
            NavigationLink {
                HomeView()
            } label: {
                Label("Pedido simples", systemImage: "shippingbox")
            }
        } footer: {
            Text("O fluxo já publicado continua disponível durante a migração.")
        }
    }

    private func metricRow(_ title: String, count: Int, systemImage: String) -> some View {
        LabeledContent {
            Text("\(count)")
                .monospacedDigit()
        } label: {
            Label(title, systemImage: systemImage)
        }
    }

    private func count(_ status: SalesOrderStatus) -> Int {
        fastOrderViewModel.savedOrders.filter { $0.status == status }.count
    }

    private func deadlineText(on date: Date) -> String {
        guard let deadline = settings.deadline(on: date) else { return "—" }
        return deadline.formatted(date: .omitted, time: .shortened)
    }

    private func operatingHoursText(on date: Date) -> String {
        guard let start = settings.startTime(on: date) else { return deadlineText(on: date) }
        return "\(start.formatted(date: .omitted, time: .shortened))–\(deadlineText(on: date))"
    }

    private func remainingText(at date: Date) -> String {
        guard let deadline = settings.deadline(on: date) else {
            return "Horário indisponível"
        }
        let minutes = Int(deadline.timeIntervalSince(date) / 60)
        if minutes < 0 { return "Prazo encerrado há \(-minutes) min" }
        if minutes == 0 { return "Prazo encerrando agora" }
        let hours = minutes / 60
        let remainder = minutes % 60
        return hours > 0 ? "Faltam \(hours)h \(remainder)min" : "Faltam \(minutes) min"
    }

    private func deadlineColor(at date: Date) -> Color {
        guard let deadline = settings.deadline(on: date) else { return .secondary }
        let minutes = deadline.timeIntervalSince(date) / 60
        if minutes <= 10 { return .red }
        if minutes <= 30 { return .orange }
        return .primary
    }
}

private extension String {
    var nilIfBlank: String? {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}

#Preview("Central do Dia") {
    DailySalesView(products: [])
        .environmentObject(OrderViewModel())
}
