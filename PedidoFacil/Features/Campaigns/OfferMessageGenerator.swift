import Foundation

struct OfferMessageGenerator {
    let locale: Locale

    init(locale: Locale = .current) {
        self.locale = locale
    }

    func generate(
        campaign: SalesCampaign,
        deadline: LocalTime?,
        signature: String?,
        compact: Bool
    ) -> String {
        let selectedItems = compact
            ? campaign.items.filter(\.isPriority)
            : campaign.items
        let items = selectedItems.isEmpty ? campaign.items : selectedItems
        guard !items.isEmpty else { return "" }

        var lines = [campaign.title.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()]
        let groups = Dictionary(grouping: items, by: \.category)
        for category in groups.keys.sorted(by: localizedAscending) {
            lines.append("")
            lines.append(category)
            for item in groups[category, default: []].sorted(by: { localizedAscending($0.name, $1.name) }) {
                let unit = item.unit.map { " / \($0)" } ?? ""
                lines.append("• \(item.name) \(item.brand) — \(currency(item.price))\(unit)")
            }
        }
        if let deadline {
            lines.append("")
            lines.append("Pedidos até \(String(format: "%02d:%02d", deadline.hour, deadline.minute)).")
        }
        if let signature = signature?.trimmingCharacters(in: .whitespacesAndNewlines), !signature.isEmpty {
            lines.append(signature)
        }
        return lines.joined(separator: "\n")
    }

    private func currency(_ value: Decimal) -> String {
        value.formatted(.currency(code: locale.currency?.identifier ?? "BRL").locale(locale))
    }

    private func localizedAscending(_ lhs: String, _ rhs: String) -> Bool {
        lhs.localizedCompare(rhs) == .orderedAscending
    }
}
