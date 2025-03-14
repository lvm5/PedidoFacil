//
//  Profit.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-03-12.
//


@Model
class Profit {
    @Attribute(.unique) var id: UUID
    var orderId: UUID
    var clientName: String
    var totalProfit: Decimal