//
//  ProductPickerView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-17.
//

import SwiftUI

@available(iOS 26.0, *)
struct ProfitView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = OrderViewModel()
    
    // Cores personalizadas
    private let primaryColor = Color(red: 0.3, green: 0.4, blue: 0.9)
    private let secondaryColor = Color(red: 0.9, green: 0.3, blue: 0.4)
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()

                VStack(spacing: 0) {
                    HeaderView(
                        title: "Resumo de Lucros",
                        primaryColor: primaryColor,
                        onClearAll: viewModel.clearAllOrders,
                        isClearDisabled: viewModel.orders.isEmpty
                    )

                    ScrollView {
                        FinancialSummaryView(orders: viewModel.orders)
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        HomeView()
    } else {
        Text("Preview not available")
    }
}
