import SwiftUI

struct DailySalesView: View {
    @State private var settings: OperationalSettings
    @State private var fastOrderViewModel: FastOrderViewModel
    @State private var showingSettings = false

    private let products: [Product]

    init(products: [Product]) {
        self.products = products
        _settings = State(initialValue: OperationalSettings())
        _fastOrderViewModel = State(
            initialValue: FastOrderViewModel(
                products: products,
                customers: CustomerStore().activeCustomers
            )
        )
    }

    var body: some View {
        NavigationStack {
            List {
                deadlineSection
                actionsSection
                pendingSection
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

    private var deadlineSection: some View {
        Section {
            TimelineView(.periodic(from: .now, by: 60)) { context in
                VStack(alignment: .leading, spacing: 6) {
                    LabeledContent(
                        "Horário limite",
                        value: deadlineText(on: context.date)
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
                    viewModel: PriceListImportViewModel(
                        knownBrands: Array(Set(products.compactMap(\.brand))),
                        knownCategories: Array(Set(products.map(\.category)))
                    )
                )
            } label: {
                Label("Importar lista", systemImage: "doc.on.clipboard")
            }

            NavigationLink {
                FastOrderView(viewModel: fastOrderViewModel)
            } label: {
                Label("Criar pedido", systemImage: "cart.badge.plus")
            }

            NavigationLink {
                CampaignListView(
                    campaignStore: CampaignStore(),
                    customerStore: CustomerStore(),
                    priceListStore: PriceListImportViewModel(),
                    settings: settings
                )
            } label: {
                Label("Enviar ofertas", systemImage: "megaphone")
            }
        }
    }

    private var pendingSection: some View {
        Section("Pendências") {
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
