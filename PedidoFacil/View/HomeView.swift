//
//  ContentView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-15.
//

import SwiftUI

@available(iOS 26.0, *)
struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: OrderViewModel
    
    // Cores personalizadas
    private let primaryColor = Color(red: 0.3, green: 0.4, blue: 0.9)
    private let secondaryColor = Color(red: 0.9, green: 0.3, blue: 0.4)
    
    var body: some View {
        NavigationView {
            ZStack {
                //BackgroundView()
                
                VStack(spacing: 0) {
                    // Header com título
                    HeaderView(
                        title: "Pedido Fácil",
                        primaryColor: primaryColor,
                        onClearAll: viewModel.clearAllOrders,
                        isClearDisabled: viewModel.orders.isEmpty
                    )
                    
                    // Conteúdo principal
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            
                            TextField("Nome do Cliente", text: $viewModel.clientName)
                            //.textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                            
                            // Seção de seleção de produto
                            ProductSelectionView(
                                selectedProduct: $viewModel.selectedProduct,
                                showingCalculation: $viewModel.showingCalculation)
                            
                            // Seção de quantidade
                            QuantityInputView(
                                quantityKg: $viewModel.quantityKg,
                                primaryColor: primaryColor)
                            
                            // Botões de ação
                            ActionButtonsView(
                                quantityKg: viewModel.quantityKg,
                                totalPrice: viewModel.totalPrice,
                                totalProfit: viewModel.totalProfit,
                                showingCalculation: viewModel.showingCalculation,
                                onCalculate: {
                                    viewModel.calculate()
                                    viewModel.addOrder()
                                },
                                onAddOrder: viewModel.addOrder,
//                                primaryColor: primaryColor,
//                                secondaryColor: secondaryColor
                            )
                            
                            // Seção de pedidos
                            if !viewModel.orders.isEmpty {
                                CurrentOrderListView(
                                    orders: viewModel.orders,
                                    primaryColor: primaryColor,
                                    removeOrder: viewModel.removeOrder
                                )
                            }
                            // Botão Finalizar Pedido
                            if !viewModel.orders.isEmpty {
                                Button(action: {
                                    viewModel.saveClientOrder()
                                }) {
                                    Label("Finalizar Pedido", systemImage: "checkmark.circle.fill")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                            }
                        }
                        .padding(.top, 6)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
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

