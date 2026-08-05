import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class CampaignStore {
    private(set) var campaigns: [SalesCampaign] = []
    private(set) var errorMessage: String?

    private let store: JSONFileStore<[SalesCampaign]>
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "PedidoFacil",
        category: "Campaigns"
    )

    init(store: JSONFileStore<[SalesCampaign]>? = nil) {
        self.store = store ?? JSONFileStore(fileURL: Self.defaultFileURL)
        do {
            campaigns = try self.store.load()?.value ?? []
        } catch {
            errorMessage = "Não foi possível carregar as campanhas."
            logger.error("Failed to load campaigns: \(error.localizedDescription, privacy: .public)")
        }
    }

    var activeCampaigns: [SalesCampaign] {
        campaigns.filter { !$0.isArchived }.sorted { $0.updatedAt > $1.updatedAt }
    }

    @discardableResult
    func create(
        title: String,
        priceList: DailyPriceList,
        selectedItemIDs: Set<UUID>,
        priorityItemIDs: Set<UUID>,
        customerIDs: [UUID],
        now: Date = Date()
    ) -> SalesCampaign? {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let selected = priceList.items.filter { selectedItemIDs.contains($0.id) }
        guard !cleanTitle.isEmpty, !selected.isEmpty else {
            errorMessage = "Informe o título e selecione pelo menos um produto."
            return nil
        }
        guard selected.allSatisfy({ $0.price != nil && $0.brand?.isEmpty == false }) else {
            errorMessage = "Revise marca e preço de todos os produtos selecionados."
            return nil
        }

        let uniqueCustomerIDs = Array(Set(customerIDs))
        let campaign = SalesCampaign(
            title: cleanTitle,
            priceListID: priceList.id,
            items: selected.map {
                CampaignOfferItem(
                    sourceItemID: $0.id,
                    name: $0.name,
                    brand: $0.brand ?? "",
                    price: $0.price ?? 0,
                    unit: $0.unit,
                    category: $0.category ?? "Outros",
                    isPriority: priorityItemIDs.contains($0.id)
                )
            },
            customerIDs: uniqueCustomerIDs,
            interactions: uniqueCustomerIDs.map {
                CustomerInteraction(customerID: $0, createdAt: now, updatedAt: now)
            },
            createdAt: now,
            updatedAt: now
        )
        campaigns.append(campaign)
        return persist() ? campaign : nil
    }

    func updateInteraction(
        campaignID: UUID,
        customerID: UUID,
        status: CustomerInteractionStatus,
        note: String? = nil,
        now: Date = Date()
    ) {
        guard let campaignIndex = campaigns.firstIndex(where: { $0.id == campaignID }) else { return }
        let interaction = CustomerInteraction(
            customerID: customerID,
            status: status,
            createdAt: now,
            updatedAt: now,
            note: note?.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        campaigns[campaignIndex].interactions.append(interaction)
        campaigns[campaignIndex].updatedAt = now
        _ = persist()
    }

    func archive(id: UUID, now: Date = Date()) {
        guard let index = campaigns.firstIndex(where: { $0.id == id }) else { return }
        campaigns[index].archivedAt = now
        campaigns[index].updatedAt = now
        _ = persist()
    }

    private func persist() -> Bool {
        do {
            try store.save(campaigns)
            errorMessage = nil
            logger.debug("Campaign collection persisted. Count: \(self.campaigns.count, privacy: .public)")
            return true
        } catch {
            errorMessage = "Não foi possível salvar as campanhas."
            logger.error("Failed to persist campaigns: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    private static var defaultFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("salesCampaigns.json")
    }
}
