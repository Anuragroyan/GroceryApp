//
//  GroceryItem.swift
//  GroceryApp
//
//  Created by Dungeon_master on 01/07/25.
//

import Foundation

enum ItemCategory: String, Codable {
    case grocery
    case wishlist
    case cart
}

struct GroceryItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var quantity: Int
    var weightAmount: Double
    var unit: String
    var pricePerKg: Double
    var isBought: Bool
    var category: ItemCategory
    var cartQuantity: Int = 1

    var weightLabel: String {
        "\(weightAmount.clean) \(unit)"
    }

    var weightInGrams: Double {
        switch unit.lowercased() {
        case "kg": return weightAmount * 1000
        case "g": return weightAmount
        case "mg": return weightAmount / 1000
        case "lb": return weightAmount * 453.592
        default: return weightAmount
        }
    }

    var totalPrice: Double {
        let weightInKg = weightInGrams / 1000
        return weightInKg * pricePerKg * Double(quantity)
    }
}

// Only one copy of this should exist in your project
extension Double {
    var cleanString: String {
        self == floor(self) ? String(format: "%.0f", self) : String(format: "%.2f", self)
    }

    var currencyString: String {
        String(format: "₹%.2f", self)
    }
}



