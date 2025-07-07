//
//  WishlistView.swift
//  GroceryApp
//
//  Created by Dungeon_master on 01/07/25.
//

import SwiftUI

struct WishlistView: View {
    @StateObject private var viewModel = GroceryViewModel()
    @State private var searchText = ""
    @State private var selectedSort: SortOption = .none
    @State private var boughtFilter: BoughtFilter = .all

    var filteredWishlist: [GroceryItem] {
        var items = viewModel.wishlist

        // Search by name
        if !searchText.isEmpty {
            items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        // Filter by bought status
        switch boughtFilter {
        case .bought:
            items = items.filter { $0.isBought }
        case .notBought:
            items = items.filter { !$0.isBought }
        default: break
        }

        // Sorting
        switch selectedSort {
        case .nameAZ:
            items.sort { $0.name.lowercased() < $1.name.lowercased() }
        case .nameZA:
            items.sort { $0.name.lowercased() > $1.name.lowercased() }
        case .priceLowHigh:
            items.sort { $0.totalPrice < $1.totalPrice }
        case .priceHighLow:
            items.sort { $0.totalPrice > $1.totalPrice }
        default: break
        }

        return items
    }

    var body: some View {
        NavigationView {
            VStack {
                // MARK: - Search & Filters
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search wishlist...", text: $searchText)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)

                    HStack {
                        Menu {
                            Picker("Sort by", selection: $selectedSort) {
                                ForEach(SortOption.allCases) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                        } label: {
                            Label("Sort", systemImage: "arrow.up.arrow.down")
                        }

                        Menu {
                            Picker("Filter", selection: $boughtFilter) {
                                ForEach(BoughtFilter.allCases) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                        } label: {
                            Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
                        }
                    }
                    .padding(.horizontal)
                }

                // MARK: - Wishlist Items
                if filteredWishlist.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "star.slash")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray.opacity(0.6))
                        Text("No items found in wishlist.")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredWishlist) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.headline)
                                    Text("Qty: \(item.quantity), \(item.weightLabel), ₹\(item.totalPrice.clean)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button {
                                    viewModel.moveToCart(item)
                                } label: {
                                    Image(systemName: "cart.badge.plus")
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { viewModel.deleteItem(at: $0, from: .wishlist) }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("⭐ Wishlist")
        }
    }
}
