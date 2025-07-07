//
//  BillView.swift
//  GroceryApp
//
//  Created by Dungeon_master on 01/07/25.
//

import SwiftUI

struct BillView: View {
    @ObservedObject var viewModel: GroceryViewModel
    @State private var showSuccess = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var totalItems: Int {
        viewModel.cart.reduce(0) { $0 + max(0, $1.cartQuantity) }
    }

    var totalWeightInGrams: Double {
        viewModel.cart.reduce(0) { $0 + ($1.weightInGrams * Double(max(0, $1.cartQuantity))) }
    }

    var totalCost: Double {
        viewModel.cart.reduce(0) { $0 + $1.totalPrice }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.cart.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "doc.plaintext")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No items in cart.")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    VStack(spacing: 16) {
                        Text("🧾 Bill Summary")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        billRow(title: "Total Items", value: "\(totalItems)")
                        billRow(title: "Total Weight", value: "\(String(format: "%.2f", totalWeightInGrams / 1000)) kg")
                        billRow(
                            title: "Grand Total",
                            value: "₹\(String(format: "%.2f", totalCost))",
                            bold: true,
                            color: .green
                        )

                        Divider()

                        Button(action: {
                            let invalidItems = viewModel.cart.filter { $0.cartQuantity < 1 || $0.cartQuantity > 100 }

                            if !invalidItems.isEmpty {
                                alertMessage = "⚠️ One or more items in your cart have invalid quantities. Please check that all quantities are between 1 and 100."
                                showAlert = true
                                return
                            }

                            viewModel.placeOrder()
                            showSuccess = true
                        }) {
                            Label("Place Order", systemImage: "checkmark.seal.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top)
                        .alert(isPresented: $showSuccess) {
                            Alert(
                                title: Text("Order Placed ✅"),
                                message: Text("Your order has been successfully saved to history."),
                                dismissButton: .default(Text("OK"))
                            )
                        }

                        Button("Copy Receipt") {
                            let receipt = generateReceipt()
                            UIPasteboard.general.string = receipt
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding()
                }

                Spacer()
            }
            .navigationTitle("📃 Bill")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Invalid Quantity"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func billRow(title: String, value: String, bold: Bool = false, color: Color = .primary) -> some View {
        HStack {
            Text(title)
                .fontWeight(bold ? .semibold : .regular)
            Spacer()
            Text(value)
                .fontWeight(bold ? .bold : .regular)
                .foregroundColor(color)
        }
    }

    private func generateReceipt() -> String {
        var lines: [String] = ["🧾 Grocery Receipt", "--------------------"]

        for item in viewModel.cart {
            let qty = max(0, item.cartQuantity)
            lines.append("\(item.name) x\(qty) - \(item.weightLabel) @ ₹\(String(format: "%.2f", item.pricePerKg))/kg")
            lines.append("Total: ₹\(String(format: "%.2f", item.totalPrice))")
        }

        lines.append("--------------------")
        lines.append("Total Weight: \(String(format: "%.2f", totalWeightInGrams / 1000)) kg")
        lines.append("Grand Total: ₹\(String(format: "%.2f", totalCost))")

        return lines.joined(separator: "\n")
    }
}
