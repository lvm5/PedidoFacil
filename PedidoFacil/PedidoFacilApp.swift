//
//  PedidoFacilApp.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-03-12.
//

import SwiftUI

@main
@available(iOS 26.0, *)
struct PedidoFacilApp: App {
    @StateObject private var productModel = ProductModel()
    @StateObject private var orderViewModel = OrderViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .background(BackgroundView())
                .environmentObject(productModel)
                .environmentObject(orderViewModel)
        }
    }
}
