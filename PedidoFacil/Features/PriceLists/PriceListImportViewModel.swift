import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class PriceListImportViewModel {
    var sourceText = ""
    private(set) var draft: DailyPriceList?
    private(set) var savedLists: [DailyPriceList] = []
    private(set) var errorMessage: String?
    private(set) var successMessage: String?

    private let parser: PriceListParser
    private let store: JSONFileStore<[DailyPriceList]>
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "PedidoFacil",
        category: "PriceListImport"
    )

    init(
        knownBrands: [String] = [],
        knownCategories: [String] = [],
        store: JSONFileStore<[DailyPriceList]>? = nil
    ) {
        parser = PriceListParser(
            knownBrands: knownBrands,
            knownCategories: knownCategories
        )
        self.store = store ?? JSONFileStore(fileURL: Self.defaultFileURL)
        loadSavedLists()
    }

    var canReview: Bool {
        !sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canSave: Bool {
        guard let draft, !draft.items.isEmpty else { return false }
        return draft.itemsNeedingReview.isEmpty
    }

    func reviewSource() {
        guard canReview else {
            errorMessage = "Cole uma lista antes de continuar."
            return
        }

        let parsed = parser.parse(sourceText)
        guard !parsed.items.isEmpty else {
            errorMessage = "Nenhum item foi identificado. Confira o texto e tente novamente."
            return
        }

        draft = parsed
        errorMessage = nil
        successMessage = nil
        logger.info("Price list parsed. Item count: \(parsed.items.count, privacy: .public)")
    }

    func updateItem(
        id: UUID,
        name: String? = nil,
        brand: String? = nil,
        priceText: String? = nil,
        category: String? = nil,
        unit: String? = nil
    ) {
        guard var currentDraft = draft,
              let index = currentDraft.items.firstIndex(where: { $0.id == id }) else {
            return
        }

        if let name { currentDraft.items[index].name = name }
        if let brand { currentDraft.items[index].brand = brand.nilIfBlank }
        if let priceText {
            currentDraft.items[index].rawPriceText = priceText.nilIfBlank
            currentDraft.items[index].price = Self.parsePrice(priceText)
        }
        if let category { currentDraft.items[index].category = category.nilIfBlank }
        if let unit { currentDraft.items[index].unit = unit.nilIfBlank }
        currentDraft.items[index].issues = validationIssues(for: currentDraft.items[index])
        markDuplicates(in: &currentDraft.items)
        currentDraft.updatedAt = Date()
        draft = currentDraft
    }

    func removeItem(id: UUID) {
        guard var currentDraft = draft else { return }
        currentDraft.items.removeAll { $0.id == id }
        markDuplicates(in: &currentDraft.items)
        currentDraft.updatedAt = Date()
        draft = currentDraft
    }

    func saveReviewedList() {
        guard var currentDraft = draft else { return }
        revalidateAllItems(in: &currentDraft)
        draft = currentDraft

        guard canSave else {
            errorMessage = "Resolva os itens sinalizados antes de salvar."
            return
        }

        currentDraft.status = .reviewed
        currentDraft.updatedAt = Date()
        savedLists.append(currentDraft)

        do {
            try store.save(savedLists)
            draft = nil
            sourceText = ""
            errorMessage = nil
            successMessage = "Lista revisada e salva."
            logger.info("Reviewed price list saved. Item count: \(currentDraft.items.count, privacy: .public)")
        } catch {
            savedLists.removeLast()
            errorMessage = "Não foi possível salvar a lista. Tente novamente."
            logger.error("Failed to save price list: \(error.localizedDescription, privacy: .public)")
        }
    }

    func startOver() {
        draft = nil
        errorMessage = nil
        successMessage = nil
    }

    private func loadSavedLists() {
        do {
            savedLists = try store.load()?.value ?? []
        } catch {
            errorMessage = "Não foi possível carregar as listas salvas."
            logger.error("Failed to load price lists: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func revalidateAllItems(in draft: inout DailyPriceList) {
        for index in draft.items.indices {
            draft.items[index].issues = validationIssues(for: draft.items[index])
        }
        markDuplicates(in: &draft.items)
    }

    private func validationIssues(for item: PriceListItem) -> Set<PriceListItemIssue> {
        var issues: Set<PriceListItemIssue> = []
        if item.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.insert(.missingName)
        }
        if item.brand?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != false {
            issues.insert(.missingBrand)
        }
        if item.price == nil { issues.insert(.missingPrice) }
        return issues
    }

    private func markDuplicates(in items: inout [PriceListItem]) {
        for index in items.indices {
            items[index].issues.remove(.duplicate)
        }

        let groups = Dictionary(grouping: items.indices) { index in
            [items[index].name, items[index].brand ?? "", items[index].unit ?? ""]
                .joined(separator: "|")
                .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                .lowercased()
        }
        for indices in groups.values where indices.count > 1 {
            for index in indices { items[index].issues.insert(.duplicate) }
        }
    }

    private static func parsePrice(_ text: String) -> Decimal? {
        let sanitized = text
            .replacingOccurrences(of: "R$", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true
        return (formatter.number(from: sanitized) as? NSDecimalNumber)?.decimalValue
            ?? Decimal(string: sanitized.replacingOccurrences(of: ",", with: "."))
    }

    private static var defaultFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("dailyPriceLists.json")
    }
}

private extension String {
    var nilIfBlank: String? {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
