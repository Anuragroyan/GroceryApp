//
//  ContentView.swift
//  GroceryApp
//
//  Created by Dungeon_master on 01/07/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GroceryViewModel()

    var body: some View {
        TabView {
            GroceryListView()
                .tabItem {
                    Label("Groceries", systemImage: "list.bullet")
                }

            WishlistView()
                .tabItem {
                    Label("Wishlist", systemImage: "heart")
                }

            CartView(viewModel: viewModel)
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
                .badge(viewModel.cart.reduce(0) { $0 + $1.cartQuantity })

            BillView(viewModel: GroceryViewModel())
                .tabItem {
                    Label("Bill", systemImage: "creditcard")
                }

            OrderHistoryView(viewModel: GroceryViewModel())
                .tabItem {
                    Label("Orders", systemImage: "clock")
                }
        }
    }
}
