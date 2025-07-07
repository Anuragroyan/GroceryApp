//
//  GroceryViewModel.swift
//  GroceryApp
//
//  Created by Dungeon_master on 01/07/25.
//

import Foundation

class GroceryViewModel: ObservableObject {
    @Published var items: [GroceryItem] = [] {
        didSet { saveItems() }
    }

    @Published var orderHistory: [Order] = []

    private let itemsKey = "grocery_items"
    private let orderKey = "order_history"

    init() {
        loadItems()
        loadOrderHistory()
    }

    // MARK: - Computed Views
    var groceries: [GroceryItem] { items.filter { $0.category == .grocery } }
    var wishlist: [GroceryItem] { items.filter { $0.category == .wishlist } }
    var cart: [GroceryItem] { items.filter { $0.category == .cart && $0.cartQuantity > 0 } }

    // MARK: - Item Operations
    func addItem(
        name: String,
        quantity: Int,
        weightAmount: Double,
        unit: String,
        pricePerKg: Double,
        category: ItemCategory = .grocery
    ) {
        let item = GroceryItem(
            id: UUID(),
            name: name,
            quantity: quantity,
            weightAmount: weightAmount,
            unit: unit,
            pricePerKg: pricePerKg,
            isBought: false,
            category: category,
            cartQuantity: 1
        )
        items.append(item)
    }

    func toggleItem(_ item: GroceryItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isBought.toggle()
        }
    }

    func deleteItem(at offsets: IndexSet, from category: ItemCategory) {
        let filteredItems = items.enumerated().filter { $0.element.category == category }
        let indicesToRemove = offsets.map { filteredItems[$0].offset }
        for index in indicesToRemove.sorted(by: >) {
            items.remove(at: index)
        }
    }

    func moveToCart(_ item: GroceryItem) {
        updateCategory(of: item, to: .cart)
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].cartQuantity = max(1, items[index].cartQuantity)
        }
    }

    func moveToWishlist(_ item: GroceryItem) {
        updateCategory(of: item, to: .wishlist)
    }

    private func updateCategory(of item: GroceryItem, to category: ItemCategory) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].category = category
        }
    }

    // MARK: - Cart Quantity Operations
    func incrementCartQuantity(for item: GroceryItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].cartQuantity += 1
    }

    func decrementCartQuantity(for item: GroceryItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        if items[index].cartQuantity > 1 {
            items[index].cartQuantity -= 1
        } else {
            items[index].cartQuantity = 0
        }
    }

    // MARK: - Order Handling
    func placeOrder() {
        let orderItems = cart.map {
            OrderItem(
                name: $0.name,
                quantity: $0.cartQuantity,
                weightAmount: $0.weightAmount,
                unit: $0.unit,
                pricePerKg: $0.pricePerKg
            )
        }

        guard !orderItems.isEmpty else { return }

        let newOrder = Order(date: Date(), items: orderItems)
        orderHistory.append(newOrder)
        saveOrderHistory()

        // Remove cart items
        items.removeAll { $0.category == .cart }
    }

    func clearOrderHistory() {
        orderHistory = []
        UserDefaults.standard.removeObject(forKey: orderKey)
    }

    // MARK: - Persistence
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: itemsKey)
        }
    }

    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: itemsKey),
           let decoded = try? JSONDecoder().decode([GroceryItem].self, from: data) {
            items = decoded
        }
    }

    private func saveOrderHistory() {
        if let encoded = try? JSONEncoder().encode(orderHistory) {
            UserDefaults.standard.set(encoded, forKey: orderKey)
        }
    }

    private func loadOrderHistory() {
        if let data = UserDefaults.standard.data(forKey: orderKey),
           let decoded = try? JSONDecoder().decode([Order].self, from: data) {
            orderHistory = decoded
        }
    }
}
