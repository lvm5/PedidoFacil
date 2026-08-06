import SwiftUI

@available(iOS 18.0, *)
struct ProductRowView: View {
    let product: Product

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)

                if let brand = product.brand, !brand.isEmpty {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                let details = [product.category, product.packageSize ?? ""]
                    .filter { !$0.isEmpty }
                    .joined(separator: " · ")
                if !details.isEmpty {
                    Text(details)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if product.purchasePriceIsProvisional == true {
                    Label("Custo provisório", systemImage: "exclamationmark.circle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            Spacer()

            Text(product.sellingPrice.asCurrency())
                .font(.headline)
        }
        .contentShape(Rectangle())
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ProductRowView(
        product: Product(
            name: "Produto Teste",
            purchasePrice: 10,
            sellingPrice: 15,
            packageType: "Pacote",
            packageSize: "1kg",
            unitsPerPackage: 1,
            category: "Teste"
        )
    )
    .padding()
}
