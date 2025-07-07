//
//  Extension.swift
//  GroceryApp
//
//  Created by Dungeon_master on 02/07/25.
//

import Foundation

extension Double {
    var clean: String {
        self == floor(self) ? String(format: "%.0f", self) : String(format: "%.2f", self)
    }
}
