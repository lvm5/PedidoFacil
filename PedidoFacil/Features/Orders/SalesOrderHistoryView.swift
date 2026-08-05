import SwiftUI

struct SalesOrderHistoryView: View {
    enum Period: String, CaseIterable, Identifiable {
        case today = "Hoje"
        case yesterday = "Ontem"
        case week = "Semana"
        case all = "Todos"

        var id: Self { self }
    }

    let viewModel: FastOrderViewModel

    @State private var period: Period = .today
    @State private var status: SalesOrderStatus?
    @State private var onlyDiscounts = false
    @State private var query = ""

    var body: some View {
        List {
            Section("Filtros") {
                Picker("Período", selection: $period) {
                    ForEach(Period.allCases) { Text($0.rawValue).tag($0) }
                }
                Picker("Status", selection: $status) {
                    Text("Todos").tag(SalesOrderStatus?.none)
                    ForEach(SalesOrderStatus.allCases, id: \.self) {
                        Text(statusLabel($0)).tag(Optional($0))
                    }
                }
                Toggle("Somente com ajuste de preço", isOn: $onlyDiscounts)
            }

            Section("Pedidos") {
                if filteredOrders.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    ForEach(filteredOrders) { order in
                        DisclosureGroup {
                            ForEach(order.statusHistory) { change in
                                LabeledContent(
                                    statusLabel(change.status),
                                    value: change.changedAt.formatted(date: .abbreviated, time: .shortened)
                                )
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(order.customerName).font(.headline)
                                Text("\(statusLabel(order.status)) · \(currency(order.negotiatedTotal))")
                                    .foregroundStyle(.secondary)
                                Text(order.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Histórico comercial")
        .searchable(text: $query, prompt: "Cliente")
    }

    private var filteredOrders: [SalesOrder] {
        viewModel.savedOrders
            .filter(matchesPeriod)
            .filter { status == nil || $0.status == status }
            .filter { !onlyDiscounts || $0.requiresPriceAdjustment }
            .filter { query.isEmpty || $0.customerName.localizedCaseInsensitiveContains(query) }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    private func matchesPeriod(_ order: SalesOrder) -> Bool {
        let calendar = Calendar.current
        switch period {
        case .today:
            return calendar.isDateInToday(order.updatedAt)
        case .yesterday:
            return calendar.isDateInYesterday(order.updatedAt)
        case .week:
            guard let start = calendar.date(byAdding: .day, value: -7, to: Date()) else { return true }
            return order.updatedAt >= start
        case .all:
            return true
        }
    }

    private func statusLabel(_ status: SalesOrderStatus) -> String {
        switch status {
        case .draft: "Rascunho"
        case .awaitingCustomer: "Aguardando cliente"
        case .confirmed: "Confirmado"
        case .awaitingDiscountApproval: "Aguardando ajuste"
        case .readyToSubmit: "Pronto para lançamento"
        case .submitted: "Lançado"
        case .completed: "Concluído"
        case .cancelled: "Cancelado"
        }
    }

    private func currency(_ value: Decimal) -> String {
        value.formatted(.currency(code: Locale.current.currency?.identifier ?? "BRL"))
    }
}

#Preview("Histórico vazio") {
    NavigationStack {
        SalesOrderHistoryView(
            viewModel: FastOrderViewModel(
                products: [],
                store: JSONFileStore(
                    fileURL: FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString)
                        .appendingPathComponent("orders.json")
                )
            )
        )
    }
}
