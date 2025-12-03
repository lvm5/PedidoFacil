import Foundation

extension Double {
    func asCurrency(locale: Locale = Locale.current) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter.string(from: NSNumber(value: self)) ?? "R$\(String(format: "%.2f", self))"
    }
}
