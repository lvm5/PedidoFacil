import XCTest
@testable import PedidoFacil

@MainActor
final class CampaignStoreTests: XCTestCase {
    func testCampaignPreservesReviewedProductValuesAndInteractionHistory() throws {
        let fileStore = temporaryStore()
        let store = CampaignStore(store: fileStore)
        let customerID = UUID()
        let item = PriceListItem(
            sourceLineNumber: 1,
            originalLine: "Queijo Marca R$ 10,50",
            name: "Queijo",
            brand: "Marca",
            price: 10.50,
            rawPriceText: "10,50",
            unit: "kg",
            category: "Frios"
        )
        let list = DailyPriceList(sourceText: item.originalLine, status: .reviewed, items: [item])

        let campaign = try XCTUnwrap(store.create(
            title: "Ofertas do dia",
            priceList: list,
            selectedItemIDs: [item.id],
            priorityItemIDs: [item.id],
            customerIDs: [customerID, customerID]
        ))
        store.updateInteraction(
            campaignID: campaign.id,
            customerID: customerID,
            status: .sent,
            now: Date(timeIntervalSince1970: 200)
        )
        let restored = CampaignStore(store: fileStore)
        let saved = try XCTUnwrap(restored.campaigns.first)

        XCTAssertEqual(saved.customerIDs, [customerID])
        XCTAssertEqual(saved.items.first?.price, Decimal(string: "10.5"))
        XCTAssertEqual(saved.items.first?.brand, "Marca")
        XCTAssertEqual(saved.interactions.map(\.status), [.notContacted, .sent])
        XCTAssertEqual(saved.interactionStatus(for: customerID), .sent)
    }

    func testOfferMessageUsesConfiguredDeadlineAndReviewedValues() {
        let campaign = SalesCampaign(
            title: "Ofertas do dia",
            items: [
                CampaignOfferItem(
                    name: "Mussarela",
                    brand: "São Leopoldo",
                    price: Decimal(string: "36.49")!,
                    unit: "kg",
                    category: "Frios",
                    isPriority: true
                )
            ]
        )

        let message = OfferMessageGenerator(locale: Locale(identifier: "pt_BR")).generate(
            campaign: campaign,
            deadline: LocalTime(hour: 18, minute: 15),
            signature: "Equipe Norte",
            compact: true
        )

        XCTAssertTrue(message.contains("Mussarela São Leopoldo"))
        XCTAssertTrue(message.contains("R$ 36,49"))
        XCTAssertTrue(message.contains("Pedidos até 18:15."))
        XCTAssertTrue(message.contains("Equipe Norte"))
    }

    func testFailedSaveDoesNotExposeUnpersistedCampaign() {
        let store = CampaignStore(
            store: JSONFileStore(fileURL: URL(fileURLWithPath: "/dev/null/campaigns.json"))
        )
        let item = PriceListItem(
            sourceLineNumber: 1,
            originalLine: "Produto | Marca | kg | 10,00",
            name: "Produto",
            brand: "Marca",
            price: 10
        )
        let list = DailyPriceList(sourceText: item.originalLine, status: .active, items: [item])

        let campaign = store.create(
            title: "Oferta",
            priceList: list,
            selectedItemIDs: [item.id],
            priorityItemIDs: [],
            customerIDs: []
        )

        XCTAssertNil(campaign)
        XCTAssertTrue(store.campaigns.isEmpty)
        XCTAssertNotNil(store.errorMessage)
    }

    private func temporaryStore() -> JSONFileStore<[SalesCampaign]> {
        JSONFileStore(
            fileURL: FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathComponent("campaigns.json")
        )
    }
}
