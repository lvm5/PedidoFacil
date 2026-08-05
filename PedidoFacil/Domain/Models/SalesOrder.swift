import Foundation

enum SalesOrderStatus: String, Codable, CaseIterable {
    case draft
    case awaitingCustomer
    case confirmed
    case awaitingDiscountApproval
    case readyToSubmit
    case submitted
    case completed
    case cancelled
}

struct SalesOrderStatusChange: Identifiable, Codable, Equatable {
    let id: UUID
    let status: SalesOrderStatus
    let changedAt: Date
    let note: String?

    init(
        id: UUID = UUID(),
        status: SalesOrderStatus,
        changedAt: Date,
        note: String? = nil
    ) {
        self.id = id
        self.status = status
        self.changedAt = changedAt
        self.note = note
    }
}

struct SalesOrderItem: Identifiable, Codable, Equatable {
    let id: UUID
    let productID: UUID?
    var productName: String
    var brand: String?
    var quantity: Decimal
    var unit: String
    var listPrice: Decimal
    var negotiatedPrice: Decimal
    var note: String?

    init(
        id: UUID = UUID(),
        productID: UUID? = nil,
        productName: String,
        brand: String? = nil,
        quantity: Decimal,
        unit: String,
        listPrice: Decimal,
        negotiatedPrice: Decimal? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.productID = productID
        self.productName = productName
        self.brand = brand
        self.quantity = quantity
        self.unit = unit
        self.listPrice = listPrice
        self.negotiatedPrice = negotiatedPrice ?? listPrice
        self.note = note
    }

    var listSubtotal: Decimal { quantity * listPrice }
    var negotiatedSubtotal: Decimal { quantity * negotiatedPrice }
    var unitDifference: Decimal { listPrice - negotiatedPrice }
    var totalDifference: Decimal { listSubtotal - negotiatedSubtotal }
    var hasPriceAdjustment: Bool { negotiatedPrice != listPrice }
    var hasDiscount: Bool { negotiatedPrice < listPrice }

    var discountPercentage: Decimal {
        guard listPrice > 0, hasDiscount else { return 0 }
        return (unitDifference / listPrice) * 100
    }
}

enum DiscountRequestStatus: String, Codable, CaseIterable {
    case draft
    case sent
    case adjusted
    case refused
    case substituted
}

struct DiscountRequest: Identifiable, Codable, Equatable {
    let id: UUID
    let orderID: UUID
    var itemIDs: [UUID]
    var reason: String
    var status: DiscountRequestStatus
    let createdAt: Date
    var sentAt: Date?
    var resolvedAt: Date?

    init(
        id: UUID = UUID(),
        orderID: UUID,
        itemIDs: [UUID],
        reason: String,
        status: DiscountRequestStatus = .draft,
        createdAt: Date = Date(),
        sentAt: Date? = nil,
        resolvedAt: Date? = nil
    ) {
        self.id = id
        self.orderID = orderID
        self.itemIDs = itemIDs
        self.reason = reason
        self.status = status
        self.createdAt = createdAt
        self.sentAt = sentAt
        self.resolvedAt = resolvedAt
    }
}

enum SalesOrderTransitionError: Error, Equatable {
    case invalidTransition(from: SalesOrderStatus, to: SalesOrderStatus)
    case discountResolutionRequired
}

struct SalesOrder: Identifiable, Codable, Equatable {
    let id: UUID
    var customerID: UUID?
    var customerName: String
    var createdAt: Date
    var updatedAt: Date
    var status: SalesOrderStatus
    var items: [SalesOrderItem]
    var note: String?
    var discountRequest: DiscountRequest?
    var statusHistory: [SalesOrderStatusChange]

    init(
        id: UUID = UUID(),
        customerID: UUID? = nil,
        customerName: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        status: SalesOrderStatus = .draft,
        items: [SalesOrderItem] = [],
        note: String? = nil,
        discountRequest: DiscountRequest? = nil,
        statusHistory: [SalesOrderStatusChange]? = nil
    ) {
        self.id = id
        self.customerID = customerID
        self.customerName = customerName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.status = status
        self.items = items
        self.note = note
        self.discountRequest = discountRequest
        self.statusHistory = statusHistory ?? [
            SalesOrderStatusChange(status: status, changedAt: createdAt)
        ]
    }

    var listTotal: Decimal {
        items.reduce(0) { $0 + $1.listSubtotal }
    }

    var negotiatedTotal: Decimal {
        items.reduce(0) { $0 + $1.negotiatedSubtotal }
    }

    var totalDifference: Decimal { listTotal - negotiatedTotal }
    var itemsRequiringAdjustment: [SalesOrderItem] { items.filter(\.hasPriceAdjustment) }
    var requiresPriceAdjustment: Bool { !itemsRequiringAdjustment.isEmpty }

    mutating func confirm(at date: Date = Date()) throws {
        try transition(to: .confirmed, at: date)
        if requiresPriceAdjustment {
            try transition(to: .awaitingDiscountApproval, at: date)
        } else {
            try transition(to: .readyToSubmit, at: date)
        }
    }

    mutating func createDiscountRequest(reason: String, at date: Date = Date()) {
        discountRequest = DiscountRequest(
            orderID: id,
            itemIDs: itemsRequiringAdjustment.map(\.id),
            reason: reason,
            createdAt: date
        )
        updatedAt = date
    }

    mutating func markDiscountSent(at date: Date = Date()) {
        discountRequest?.status = .sent
        discountRequest?.sentAt = date
        updatedAt = date
    }

    mutating func resolveDiscount(
        as resolution: DiscountRequestStatus,
        at date: Date = Date()
    ) throws {
        guard [.adjusted, .refused, .substituted].contains(resolution) else {
            throw SalesOrderTransitionError.discountResolutionRequired
        }
        discountRequest?.status = resolution
        discountRequest?.resolvedAt = date
        updatedAt = date

        if resolution == .adjusted || resolution == .substituted {
            try transition(to: .readyToSubmit, at: date)
        }
    }

    mutating func transition(
        to newStatus: SalesOrderStatus,
        at date: Date = Date(),
        note: String? = nil
    ) throws {
        guard Self.allowedTransitions[status, default: []].contains(newStatus) else {
            throw SalesOrderTransitionError.invalidTransition(from: status, to: newStatus)
        }
        if status == .awaitingDiscountApproval, newStatus == .readyToSubmit {
            guard discountRequest?.status == .adjusted || discountRequest?.status == .substituted else {
                throw SalesOrderTransitionError.discountResolutionRequired
            }
        }

        status = newStatus
        updatedAt = date
        statusHistory.append(
            SalesOrderStatusChange(status: newStatus, changedAt: date, note: note)
        )
    }

    private static let allowedTransitions: [SalesOrderStatus: Set<SalesOrderStatus>] = [
        .draft: [.awaitingCustomer, .confirmed, .cancelled],
        .awaitingCustomer: [.confirmed, .cancelled],
        .confirmed: [.awaitingDiscountApproval, .readyToSubmit, .cancelled],
        .awaitingDiscountApproval: [.readyToSubmit, .cancelled],
        .readyToSubmit: [.submitted, .cancelled],
        .submitted: [.completed, .cancelled],
        .completed: [],
        .cancelled: []
    ]
}
