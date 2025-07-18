//
//  PurchaseSuggestionsView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-17.
//


import SwiftUI

struct PurchaseSuggestionsView: View {
    @EnvironmentObject var viewModel: OrderViewModel
    let primaryColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HeaderView(
                title: "Total dos pedidos",
                primaryColor: primaryColor,
                onClearAll: viewModel.clearAllOrders,
                isClearDisabled: viewModel.orders.isEmpty
            )
            
            Text("📦 Lista de Compras Sugerida")
                .font(.headline)

            if viewModel.purchaseList.isEmpty {
                Text("Nenhum produto ainda atingiu a quantidade mínima de compra.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.purchaseList) { product in
                    Text("🟢 \(product.name) \(product.brand ?? "") – comprar \(product.calculatedUnits ?? 1) \(product.packageType)")
                        .font(.subheadline)
                }
            }


            Divider()

            Text("⏳ Produtos em Espera")
                .font(.headline)

            if viewModel.pendingList.isEmpty {
                Text("Nenhum produto aguardando nova demanda.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.pendingList) { product in
                    let totalKg = viewModel.orders
                        .filter { $0.product == product }
                        .map { $0.quantity }
                        .reduce(0, +)
                    let sobraKg = totalKg.truncatingRemainder(dividingBy: Double(product.unitsPerPackage))

                    Text("🟡 \(product.name) \(product.brand ?? "") – espera: \(sobraKg, specifier: "%.2f")kg")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

}

#Preview {
    PurchaseSuggestionsView()
        .environmentObject(OrderViewModel())
        .padding()
        .previewLayout(.sizeThatFits)
}
