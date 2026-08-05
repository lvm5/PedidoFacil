import SwiftUI

struct PriceListImportView: View {
    @State private var viewModel: PriceListImportViewModel

    init(viewModel: PriceListImportViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let draft = viewModel.draft {
                    reviewView(draft)
                } else {
                    sourceInputView
                }
            }
            .navigationTitle(viewModel.draft == nil ? "Importar lista" : "Revisar produtos")
            .safeAreaInset(edge: .bottom) {
                primaryAction
            }
        }
    }

    private var sourceInputView: some View {
        Form {
            Section {
                TextEditor(text: $viewModel.sourceText)
                    .frame(minHeight: 220)
                    .accessibilityLabel("Texto da lista de preços")
            } header: {
                Text("Cole a lista recebida")
            } footer: {
                Text("O texto original será preservado. Marcas, preços ou linhas ambíguas precisarão de confirmação.")
            }

            if let successMessage = viewModel.successMessage {
                Section {
                    Label(successMessage, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            errorSection
        }
    }

    private func reviewView(_ draft: DailyPriceList) -> some View {
        List {
            Section {
                LabeledContent("Itens", value: "\(draft.items.count)")
                LabeledContent("Para revisar", value: "\(draft.itemsNeedingReview.count)")
            } footer: {
                Text("Confira cada marca e preço com a fonte antes de salvar.")
            }

            ForEach(draft.items) { item in
                PriceListReviewRow(
                    item: item,
                    onUpdate: { name, brand, price, category, unit in
                        viewModel.updateItem(
                            id: item.id,
                            name: name,
                            brand: brand,
                            priceText: price,
                            category: category,
                            unit: unit
                        )
                    },
                    onDelete: { viewModel.removeItem(id: item.id) }
                )
            }

            errorSection
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Voltar") { viewModel.startOver() }
            }
        }
    }

    @ViewBuilder
    private var errorSection: some View {
        if let errorMessage = viewModel.errorMessage {
            Section {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .accessibilityLabel("Erro: \(errorMessage)")
            }
        }
    }

    private var primaryAction: some View {
        Button {
            if viewModel.draft == nil {
                viewModel.reviewSource()
            } else {
                viewModel.saveReviewedList()
            }
        } label: {
            Text(viewModel.draft == nil ? "Revisar produtos" : "Salvar lista revisada")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.draft == nil ? !viewModel.canReview : !viewModel.canSave)
        .padding()
        .background(.bar)
    }
}

private struct PriceListReviewRow: View {
    let item: PriceListItem
    let onUpdate: (String, String, String, String, String) -> Void
    let onDelete: () -> Void

    @State private var name: String
    @State private var brand: String
    @State private var price: String
    @State private var category: String
    @State private var unit: String

    init(
        item: PriceListItem,
        onUpdate: @escaping (String, String, String, String, String) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.item = item
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _name = State(initialValue: item.name)
        _brand = State(initialValue: item.brand ?? "")
        _price = State(initialValue: item.rawPriceText ?? "")
        _category = State(initialValue: item.category ?? "")
        _unit = State(initialValue: item.unit ?? "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Linha \(item.sourceLineNumber): \(item.originalLine)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)

            TextField("Produto", text: $name)
            TextField("Marca", text: $brand)
            HStack {
                TextField("Preço", text: $price)
                    .keyboardType(.decimalPad)
                TextField("Unidade", text: $unit)
            }
            TextField("Categoria", text: $category)

            if !item.issues.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(item.issues.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { issue in
                        Label(label(for: issue), systemImage: "exclamationmark.circle")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }

            HStack {
                Button("Aplicar correções") {
                    onUpdate(name, brand, price, category, unit)
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Remover", role: .destructive, action: onDelete)
            }
        }
        .padding(.vertical, 6)
    }

    private func label(for issue: PriceListItemIssue) -> String {
        switch issue {
        case .missingName: "Nome obrigatório"
        case .missingBrand: "Confirmar marca"
        case .missingPrice: "Confirmar preço"
        case .duplicate: "Possível duplicidade"
        case .ambiguousDescriptor: "Descrição ambígua"
        }
    }
}

#Preview("Importar lista") {
    PriceListImportView(viewModel: PriceListImportViewModel())
}

#Preview("Revisar lista") {
    let model = PriceListImportViewModel(knownBrands: ["São Leopoldo"])
    model.sourceText = "Mussarela São Leopoldo — R$ 36,49 kg\nPresunto R$ 18,79 kg"
    model.reviewSource()
    return PriceListImportView(viewModel: model)
}
