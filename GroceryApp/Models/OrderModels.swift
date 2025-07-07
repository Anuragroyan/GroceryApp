//
//  OrderModels.swift
//  GroceryApp
//
//  Created by Dungeon_master on 01/07/25.
//

import Foundation

struct OrderItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let quantity: Int
    let weightAmount: Double
    let unit: String
    let pricePerKg: Double

    var weightLabel: String {
        "\(weightAmount.clean)\(unit)"
    }

    var weightInGrams: Double {
        switch unit.lowercased() {
        case "kg": return weightAmount * 1000
        case "g": return weightAmount
        default: return weightAmount
        }
    }

    var totalPrice: Double {
        (weightInGrams / 1000) * pricePerKg * Double(quantity)
    }
}

struct Order: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let items: [OrderItem]

    var totalWeight: Double {
        items.reduce(0) { $0 + ($1.weightInGrams * Double($1.quantity)) }
    }

    var total: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
}


