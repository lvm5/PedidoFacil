import Foundation

struct DiscountRequestMessageGenerator {
    private let locale: Locale

    init(locale: Locale = Locale(identifier: "pt_BR")) {
        self.locale = locale
    }

    func generate(for order: SalesOrder) -> String {
        let adjustedItems = order.itemsRequiringAdjustment
        guard !adjustedItems.isEmpty else { return "" }

        var lines = [
            "AJUSTE DE PREÇO",
            "",
            "Cliente: \(order.customerName)",
            "Pedido: \(order.id.uuidString)",
            ""
        ]

        for item in adjustedItems {
            let product = [item.productName, item.brand].compactMap { $0 }.joined(separator: " — ")
            lines.append("Produto: \(product)")
            lines.append("Quantidade: \(formatNumber(item.quantity)) \(item.unit)")
            lines.append("Preço da lista: \(formatCurrency(item.listPrice))")
            lines.append("Preço negociado: \(formatCurrency(item.negotiatedPrice))")
            lines.append("Diferença: \(formatPercentage(item.discountPercentage))")
            lines.append("")
        }

        if let reason = order.discountRequest?.reason
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !reason.isEmpty {
            lines.append("Motivo: \(reason)")
        }

        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "R$ 0,00"
    }

    private func formatNumber(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 3
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "0"
    }

    private func formatPercentage(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let number = formatter.string(from: NSDecimalNumber(decimal: value)) ?? "0,00"
        return "\(number)%"
    }
}
