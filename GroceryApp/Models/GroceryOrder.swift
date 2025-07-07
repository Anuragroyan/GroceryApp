//
//  GroceryOrder.swift
//  GroceryApp
//
//  Created by Dungeon_master on 02/07/25.
//

import Foundation

struct GroceryOrder: Identifiable, Codable {
    let id: UUID
    let items: [GroceryItem]
    let date: Date

    var total: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }

    var totalWeight: Double {
        items.reduce(0) { $0 + ($1.weightInGrams * Double($1.quantity)) }
    }
}
