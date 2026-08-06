//
//  PurchaseSuggestionsView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-17.
//

import SwiftUI
import Foundation // Import Foundation to support currency formatting extension

struct PurchaseSuggestionsView: View {
    @EnvironmentObject var viewModel: OrderViewModel
    var primaryColor: Color
    
    var body: some View {
        VStack() {
            HeaderView(
                title: "Total dos pedidos",
                primaryColor: primaryColor,
                onClearAll: viewModel.clearAllOrders,
                isClearDisabled: viewModel.orders.isEmpty
            )
            // Showing total price formatted as local currency below the header
            Text(viewModel.totalPriceFromAllClientOrders.asCurrency()) // Local currency formatting
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.bottom, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("📦 Lista de Compras Sugerida")
                        .font(.headline)
                    
                    if viewModel.purchaseList.isEmpty {
                        Text("Nenhum produto ainda atingiu a quantidade mínima de compra.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.purchaseList) { product in
                            Text("🟢 \(product.name) \(product.brand ?? "") – comprar \(product.calculatedUnits ?? 1) \(product.packageType ?? "un")")
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
                            let unitsPerPackage = Double(product.unitsPerPackage ?? 1)
                            let sobraKg = totalKg.truncatingRemainder(dividingBy: unitsPerPackage)
                            
                            Text("🟡 \(product.name) \(product.brand ?? "") – espera: \(sobraKg, specifier: "%.2f")kg")
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                
                ShareLink(item: viewModel.generatePurchaseListText()) {
                    Label("Enviar Lista para o Mercado", systemImage: "paperplane.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top)
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    PurchaseSuggestionsView(primaryColor: .blue)
        .environmentObject(OrderViewModel())
        .padding()
}
