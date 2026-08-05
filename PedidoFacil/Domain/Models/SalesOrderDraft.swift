import Foundation

struct SalesOrderDraft: Codable, Equatable {
    var clientName: String
    var items: [OrderItem]
    var quantityInput: String
    var selectedProduct: Product?
    var updatedAt: Date

    var isEmpty: Bool {
        clientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && items.isEmpty
            && quantityInput.isEmpty
            && selectedProduct == nil
    }
}
