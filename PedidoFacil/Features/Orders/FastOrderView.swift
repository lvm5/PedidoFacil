import SwiftUI

struct FastOrderView: View {
    @State private var viewModel: FastOrderViewModel
    private let customerProvider: () -> [Customer]
    private let productProvider: () -> [Product]

    init(
        viewModel: FastOrderViewModel,
        customerProvider: @escaping () -> [Customer] = { [] },
        productProvider: @escaping () -> [Product] = { [] }
    ) {
        _viewModel = State(initialValue: viewModel)
        self.customerProvider = customerProvider
        self.productProvider = productProvider
    }

    var body: some View {
        Form {
            statusSection

            if viewModel.order.status == .draft {
                customerSection
                productSection
            }

            itemsSection

            if viewModel.order.status == .draft, !viewModel.previousOrders.isEmpty {
                previousOrdersSection
            }

            if viewModel.order.requiresPriceAdjustment {
                discountSection
            }

            feedbackSection
            actionSection
        }
        .navigationTitle("Pedido rápido")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.updateCustomers(customerProvider())
            let currentProducts = productProvider()
            if !currentProducts.isEmpty { viewModel.updateProducts(currentProducts) }
        }
    }

    private var statusSection: some View {
        Section {
            LabeledContent("Status", value: statusLabel(viewModel.order.status))
            LabeledContent("Total da lista", value: currency(viewModel.order.listTotal))
            LabeledContent("Total negociado", value: currency(viewModel.order.negotiatedTotal))
            if viewModel.order.totalDifference != 0 {
                LabeledContent("Diferença", value: currency(viewModel.order.totalDifference))
                    .foregroundStyle(.orange)
            }
        }
    }

    private var customerSection: some View {
        Section("Cliente") {
            if !viewModel.customers.isEmpty {
                Picker(
                    "Cliente cadastrado",
                    selection: Binding(
                        get: { viewModel.selectedCustomerID },
                        set: { viewModel.selectCustomer($0) }
                    )
                ) {
                    Text("Digitar nome").tag(UUID?.none)
                    ForEach(viewModel.customers) { customer in
                        Text(customer.name).tag(Optional(customer.id))
                    }
                }
            }
            TextField(
                "Nome do cliente",
                text: Binding(
                    get: { viewModel.customerName },
                    set: { viewModel.updateCustomerName($0) }
                )
            )
            .textContentType(.name)
        }
    }

    private var previousOrdersSection: some View {
        Section("Pedidos anteriores") {
            ForEach(viewModel.previousOrders.prefix(5)) { previous in
                Button {
                    viewModel.duplicateOrder(id: previous.id)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(previous.customerName)
                            .foregroundStyle(.primary)
                        Text("\(previous.items.count) itens · \(currency(previous.negotiatedTotal))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityHint("Cria um novo rascunho com os mesmos itens")
            }
        }
    }

    private var productSection: some View {
        Section("Adicionar produto") {
            Picker(
                "Produto",
                selection: Binding(
                    get: { viewModel.selectedProductID },
                    set: { viewModel.selectProduct($0) }
                )
            ) {
                Text("Selecione").tag(UUID?.none)
                ForEach(viewModel.products) { product in
                    Text([product.name, product.brand].compactMap { $0 }.joined(separator: " — "))
                        .tag(Optional(product.id))
                }
            }

            TextField("Quantidade", text: $viewModel.quantityText)
                .keyboardType(.decimalPad)

            TextField("Preço negociado", text: $viewModel.negotiatedPriceText)
                .keyboardType(.decimalPad)

            TextField("Observação do item", text: $viewModel.itemNote)

            Button("Adicionar item", systemImage: "plus") {
                viewModel.addItem()
            }
            .disabled(!viewModel.canAddItem)
            .accessibilityIdentifier("add-order-item")
        }
    }

    private var itemsSection: some View {
        Section("Itens") {
            if viewModel.order.items.isEmpty {
                ContentUnavailableView(
                    "Pedido vazio",
                    systemImage: "cart",
                    description: Text("Selecione um produto e informe a quantidade.")
                )
            } else {
                ForEach(viewModel.order.items) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text([item.productName, item.brand].compactMap { $0 }.joined(separator: " — "))
                            .font(.headline)
                        Text("\(number(item.quantity)) \(item.unit) · \(currency(item.negotiatedPrice))")
                            .foregroundStyle(.secondary)
                        if item.hasPriceAdjustment {
                            Text("Lista \(currency(item.listPrice)) · diferença \(currency(item.totalDifference))")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                    .swipeActions {
                        if viewModel.order.status == .draft {
                            Button("Remover", role: .destructive) {
                                viewModel.removeItem(id: item.id)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var discountSection: some View {
        Section {
            if viewModel.order.status == .draft {
                TextField("Motivo obrigatório", text: $viewModel.discountReason, axis: .vertical)
                    .lineLimit(2...4)
            } else if let request = viewModel.order.discountRequest {
                LabeledContent("Solicitação", value: discountStatusLabel(request.status))
                if !viewModel.discountMessage.isEmpty {
                    ShareLink(item: viewModel.discountMessage) {
                        Label("Compartilhar solicitação", systemImage: "square.and.arrow.up")
                    }
                }
                if request.status == .draft {
                    Button("Marcar como enviada") { viewModel.markDiscountSent() }
                }
                if request.status == .sent || request.status == .draft {
                    Button("Marcar como ajustada") {
                        viewModel.resolveDiscount(as: .adjusted)
                    }
                    Button("Marcar como substituída") {
                        viewModel.resolveDiscount(as: .substituted)
                    }
                    Button("Marcar como recusada", role: .destructive) {
                        viewModel.resolveDiscount(as: .refused)
                    }
                }
            }
        } header: {
            Text("Ajuste de preço")
        } footer: {
            Text("Compartilhar ou marcar como enviada não aprova o ajuste.")
        }
    }

    @ViewBuilder
    private var feedbackSection: some View {
        if let error = viewModel.errorMessage {
            Section {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .accessibilityLabel("Erro: \(error)")
            }
        } else if let success = viewModel.successMessage {
            Section {
                Label(success, systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
    }

    @ViewBuilder
    private var actionSection: some View {
        Section {
            switch viewModel.order.status {
            case .draft:
                Button("Revisar e confirmar") { viewModel.confirmOrder() }
                    .disabled(!viewModel.canConfirm)
                    .accessibilityIdentifier("confirm-fast-order")
            case .readyToSubmit:
                Button("Marcar como lançado") { viewModel.markSubmitted() }
                    .buttonStyle(.borderedProminent)
            case .submitted:
                Button("Concluir pedido") { viewModel.complete() }
                    .buttonStyle(.borderedProminent)
            case .completed, .cancelled:
                Button("Criar novo pedido") { viewModel.startNewOrder() }
            case .awaitingCustomer, .confirmed, .awaitingDiscountApproval:
                EmptyView()
            }

            if ![SalesOrderStatus.completed, .cancelled].contains(viewModel.order.status) {
                Button("Cancelar pedido", role: .destructive) { viewModel.cancelOrder() }
            }
        }
    }

    private func statusLabel(_ status: SalesOrderStatus) -> String {
        switch status {
        case .draft: "Rascunho"
        case .awaitingCustomer: "Aguardando cliente"
        case .confirmed: "Confirmado"
        case .awaitingDiscountApproval: "Aguardando ajuste de preço"
        case .readyToSubmit: "Pronto para lançamento"
        case .submitted: "Lançado"
        case .completed: "Concluído"
        case .cancelled: "Cancelado"
        }
    }

    private func discountStatusLabel(_ status: DiscountRequestStatus) -> String {
        switch status {
        case .draft: "Não enviada"
        case .sent: "Enviada; aguardando retorno"
        case .adjusted: "Ajustada"
        case .refused: "Recusada"
        case .substituted: "Substituída"
        }
    }

    private func currency(_ value: Decimal) -> String {
        value.formatted(.currency(code: Locale.current.currency?.identifier ?? "BRL"))
    }

    private func number(_ value: Decimal) -> String {
        value.formatted(.number.precision(.fractionLength(0...3)))
    }
}

#Preview("Pedido rápido") {
    NavigationStack {
        FastOrderView(
            viewModel: FastOrderViewModel(
                products: [
                    Product(
                        name: "Mussarela",
                        purchasePrice: 30,
                        sellingPrice: 36.49,
                        packageType: "Kg",
                        packageSize: "1kg",
                        unitsPerPackage: 1,
                        category: "Frios",
                        brand: "São Leopoldo"
                    )
                ]
            )
        )
    }
}
