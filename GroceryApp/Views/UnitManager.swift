//
//  UnitManager.swift
//  GroceryApp
//
//  Created by Dungeon_master on 01/07/25.
//

import Foundation

class UnitManager: ObservableObject {
    @Published var units: [String] {
        didSet {
            UserDefaults.standard.set(units, forKey: "customUnits")
        }
    }

    init() {
        self.units = UserDefaults.standard.stringArray(forKey: "customUnits") ?? ["g", "kg", "L", "ml", "pack"]
    }

    func addCustomUnit(_ unit: String) {
        let trimmed = unit.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !units.contains(trimmed) else { return }
        units.insert(trimmed, at: 0)
    }
}
