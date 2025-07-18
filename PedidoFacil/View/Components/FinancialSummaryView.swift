//
//  FinancialSummaryView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-17.
//


import SwiftUI

struct FinancialSummaryView: View {
    
    @EnvironmentObject var viewModel: OrderViewModel
    @Environment(\.colorScheme) var colorScheme
    
    let orders: [OrderItem]
    
    var body: some View {
        VStack(spacing: 16) {
            HeaderView(
                title: "Lista de pedidos",
                primaryColor: Color.accentColor,
                onClearAll: viewModel.clearAllOrders,
                isClearDisabled: viewModel.orders.isEmpty
            )
            
            
            Text("Resumo Financeiro")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                    
                    Text("Total Vendas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("R$ \(orders.reduce(0) { $0 + $1.totalPrice }, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                    
                    Text("Total Lucro")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("R$ \(orders.reduce(0) { $0 + $1.totalProfit }, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
 
#Preview {
    FinancialSummaryView(orders: [
        OrderItem(product: Product(name: "Produto A", purchasePrice: 10.0, sellingPrice: 15.0, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Carnes"), quantity: 5),
        OrderItem(product: Product(name: "Produto B", purchasePrice: 20.0, sellingPrice: 30.0, packageType: "Kg", packageSize: "1kg", unitsPerPackage: 1, category: "Frios"), quantity: 3)
    ])
}
