//
//  BackgroundView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-17.
//


import SwiftUI

@available(iOS 18.0, *)
struct BackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Group {
            if #available(iOS 18.0, *) {
                MeshGradient(
                    width: 3,
                    height: 4,
                    points: [
                        .init(0, 0), .init(0.5, 0), .init(1, 0),
                        .init(0, 0.3), .init(0.5, 0.3), .init(1, 0.3),
                        .init(0, 0.7), .init(0.5, 0.7), .init(1, 0.7),
                        .init(0, 1), .init(0.5, 1), .init(1, 1)
                    ],
                    colors: [
                        Color(red: 0.95, green: 0.85, blue: 0.9).opacity(0.8),
                        Color(red: 0.85, green: 0.9, blue: 0.95).opacity(0.8),
                        Color(red: 0.9, green: 0.95, blue: 0.85).opacity(0.8),
                        Color(red: 0.9, green: 0.8, blue: 0.95).opacity(0.8),
                        Color(red: 0.8, green: 0.95, blue: 0.9).opacity(0.8),
                        Color(red: 0.95, green: 0.9, blue: 0.8).opacity(0.8),
                        Color(red: 0.85, green: 0.8, blue: 0.9).opacity(0.8),
                        Color(red: 0.9, green: 0.85, blue: 0.95).opacity(0.8),
                        Color(red: 0.8, green: 0.9, blue: 0.85).opacity(0.8),
                        Color(red: 0.95, green: 0.8, blue: 0.85).opacity(0.8),
                        Color(red: 0.8, green: 0.85, blue: 0.95).opacity(0.8),
                        Color(red: 0.9, green: 0.9, blue: 0.8).opacity(0.8)
                    ]
                )
                .ignoresSafeArea()
            } else {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.85, blue: 0.9).opacity(0.8),
                        Color(red: 0.85, green: 0.9, blue: 0.95).opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
        }
    }
}