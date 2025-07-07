//
//  GroceryListView.swift
//  GroceryApp
//
//  Created by Dungeon_master on 01/07/25.
//

import SwiftUI

enum SortOption: String, CaseIterable, Identifiable {
    case none = "None"
    case nameAZ = "Name (A-Z)"
    case nameZA = "Name (Z-A)"
    case priceLowHigh = "Price ↑"
    case priceHighLow = "Price ↓"

    var id: String { rawValue }
}

enum BoughtFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case bought = "Bought"
    case notBought = "Not Bought"

    var id: String { rawValue }
}

struct GroceryListView: View {
    @StateObject private var viewModel = GroceryViewModel()
    @StateObject private var unitManager = UnitManager()

    @State private var name = ""
    @State private var quantity = ""
    @State private var weightAmount = ""
    @State private var selectedUnit = "kg"
    @State private var customUnit = ""
    @State private var pricePerKg = ""
    @State private var unitSearch = ""
    @State private var searchText = ""
    
    @State private var selectedSort: SortOption = .none
    @State private var boughtFilter: BoughtFilter = .all

    @State private var showAlert = false
    @State private var alertMessage = ""

    var filteredGroceries: [GroceryItem] {
        var items = viewModel.groceries

        if !unitSearch.isEmpty {
            items = items.filter { $0.unit.lowercased().contains(unitSearch.lowercased()) }
        }

        if !searchText.isEmpty {
            items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        switch boughtFilter {
        case .bought:
            items = items.filter { $0.isBought }
        case .notBought:
            items = items.filter { !$0.isBought }
        default:
            break
        }

        switch selectedSort {
        case .nameAZ:
            items = items.sorted { $0.name.lowercased() < $1.name.lowercased() }
        case .nameZA:
            items = items.sorted { $0.name.lowercased() > $1.name.lowercased() }
        case .priceLowHigh:
            items = items.sorted { $0.totalPrice < $1.totalPrice }
        case .priceHighLow:
            items = items.sorted { $0.totalPrice > $1.totalPrice }
        default:
            break
        }

        return items
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {

                GroupBox(label: Label("Add Grocery Item", systemImage: "plus.circle.fill")) {
                    VStack(spacing: 10) {
                        TextField("Name", text: $name)
                            .textFieldStyle(.roundedBorder)

                        HStack {
                            TextField("Quantity", text: $quantity)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)

                            TextField("Price per kg", text: $pricePerKg)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                        }

                        HStack {
                            TextField("Weight", text: $weightAmount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)

                            Picker("Unit", selection: $selectedUnit) {
                                ForEach(unitManager.units + ["Other"], id: \ .self) { unit in
                                    Text(unit).tag(unit)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: 100)

                            if selectedUnit == "Other" {
                                TextField("Custom Unit", text: $customUnit)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }

                        Button(action: addItem) {
                            Label("Add to List", systemImage: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)

                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search items", text: $searchText)
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

                    TextField("Search by unit (e.g., kg, ml)", text: $unitSearch)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                }

                if filteredGroceries.isEmpty {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "cart.badge.plus")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray.opacity(0.6))
                        Text("No grocery items found.")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredGroceries) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.headline)
                                    Text("Qty: \(item.quantity), \(item.weightLabel), ₹\(item.totalPrice.clean)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                HStack(spacing: 10) {
                                    Button {
                                        viewModel.moveToCart(item)
                                    } label: {
                                        Image(systemName: "cart.fill.badge.plus")
                                    }

                                    Button {
                                        viewModel.moveToWishlist(item)
                                    } label: {
                                        Image(systemName: "star")
                                    }
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { offsets in
                            viewModel.deleteItem(at: offsets, from: .grocery)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("🧺 Grocery List")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Input"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    func addItem() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Please enter a name."
            showAlert = true
            return
        }

        guard let qty = Int(quantity), qty > 0 else {
            alertMessage = "Quantity must be a positive number."
            showAlert = true
            return
        }

        guard let ppk = Double(pricePerKg), ppk >= 0 else {
            alertMessage = "Price per kg must be a valid number."
            showAlert = true
            return
        }

        guard let wAmt = Double(weightAmount), wAmt > 0 else {
            alertMessage = "Weight must be a positive number."
            showAlert = true
            return
        }

        let finalUnit = selectedUnit == "Other" ? customUnit.trimmingCharacters(in: .whitespaces) : selectedUnit
        guard !finalUnit.isEmpty else {
            alertMessage = "Please enter a valid unit."
            showAlert = true
            return
        }

        if selectedUnit == "Other" {
            unitManager.addCustomUnit(finalUnit)
        }

        viewModel.addItem(
            name: name,
            quantity: qty,
            weightAmount: wAmt,
            unit: finalUnit,
            pricePerKg: ppk
        )

        name = ""
        quantity = ""
        weightAmount = ""
        selectedUnit = "kg"
        customUnit = ""
        pricePerKg = ""
    }
}
