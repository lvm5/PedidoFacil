//
//  AppCoordinator.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-03-12.
//


import SwiftUI
import SwiftData

// MARK: - AppCoordinator
class AppCoordinator: ObservableObject {
    
    // Estado para controlar as telas
    @Published var currentView: Destination = .main
    
    // Enum para mapear cada tela
    enum Destination {
        case main
        case orderList
        case newOrder
        case checkout(Order)
    }
    
    // Navegação dinâmica para cada tela
    @ViewBuilder
    func viewForDestination() -> some View {
        switch currentView {
        case .main:
            MainView(coordinator: self)
        case .orderList:
            OrderListView(coordinator: self)
        case .newOrder:
            ContentView(order: Order(name: ""), coordinator: self)
        case .checkout(let order):
            CheckoutView(order: order, coordinator: self)
        }
    }

    // Métodos para navegar entre telas
    func goToMain() {
        currentView = .main
    }

    func goToOrderList() {
        currentView = .orderList
    }

    func goToNewOrder() {
        currentView = .newOrder
    }

    func goToCheckout(with order: Order) {
        currentView = .checkout(order)
    }
}