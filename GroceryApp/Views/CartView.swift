import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: GroceryViewModel
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var tempQuantities: [UUID: String] = [:]

    let taxRate: Double = 0.07
    let deliveryFee: Double = 20.0

    var cartItems: [GroceryItem] {
        viewModel.items.filter { $0.category == .cart && $0.cartQuantity > 0 }
    }

    var subtotal: Double {
        cartItems.reduce(0) {
            $0 + ($1.pricePerKg * $1.weightAmount * Double($1.cartQuantity))
        }
    }

    var taxAmount: Double {
        subtotal * taxRate
    }

    var grandTotal: Double {
        subtotal + taxAmount + deliveryFee
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if cartItems.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "cart.badge.minus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                        Text("Your cart is empty")
                            .foregroundColor(.gray)
                            .font(.headline)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(cartItems, id: \.id) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(item.name)
                                    .font(.title3)
                                    .fontWeight(.semibold)

                                HStack {
                                    Label("\(item.weightAmount, specifier: "%.2f") \(item.unit)", systemImage: "scalemass")
                                        .font(.subheadline)
                                    Spacer()
                                    Label("₹\(item.pricePerKg, specifier: "%.2f")/kg", systemImage: "tag")
                                        .font(.subheadline)
                                }

                                HStack {
                                    Label("Category: \(item.category.rawValue.capitalized)", systemImage: "square.grid.2x2")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)

                                    Spacer()

                                    HStack {
                                        Label("Qty", systemImage: "number")
                                        TextField("", text: Binding<String>(
                                            get: {
                                                tempQuantities[item.id] ?? String(item.cartQuantity)
                                            },
                                            set: { newValue in
                                                tempQuantities[item.id] = newValue

                                                if let qty = Int(newValue), (1...100).contains(qty) {
                                                    if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                                                        viewModel.items[index].cartQuantity = qty
                                                    }
                                                } else if let qty = Int(newValue), qty <= 0 {
                                                    alertMessage = "Quantity must be between 1 and 100."
                                                    showAlert = true
                                                    tempQuantities[item.id] = String(item.cartQuantity)
                                                }
                                            }
                                        ))
                                        .keyboardType(.numberPad)
                                        .frame(width: 50)
                                        .multilineTextAlignment(.center)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                                    .font(.subheadline)
                                }

                                let total = item.pricePerKg * item.weightAmount * Double(item.cartQuantity)
                                HStack {
                                    Spacer()
                                    Text("Total: ₹\(total, specifier: "%.2f")")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(.plain)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Subtotal")
                            Spacer()
                            Text("₹\(subtotal, specifier: "%.2f")")
                        }
                        HStack {
                            Text("Tax (7%)")
                            Spacer()
                            Text("₹\(taxAmount, specifier: "%.2f")")
                        }
                        HStack {
                            Text("Delivery Fee")
                            Spacer()
                            Text("₹\(deliveryFee, specifier: "%.2f")")
                        }
                        Divider()
                        HStack {
                            Text("Grand Total")
                                .fontWeight(.bold)
                            Spacer()
                            Text("₹\(grandTotal, specifier: "%.2f")")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    .padding()

                    Button(action: {
                        if !cartItems.isEmpty {
                            viewModel.placeOrder()
                            tempQuantities.removeAll()

                            let messages = [
                                "🎉 Thank you! Your order is being packed 🛒",
                                "✅ Groceries on the way! Sit tight.",
                                "📦 We're on it! Your order is confirmed.",
                                "🥳 Order placed! Check your order history.",
                                "🍎 Thanks! You'll receive your groceries shortly. 🧾"
                            ]

                            toastMessage = messages.randomElement() ?? "✅ Order placed!"
                            withAnimation {
                                showToast = true
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation {
                                    showToast = false
                                }
                            }
                        }
                    }) {
                        Label("Place Order", systemImage: "checkmark.seal.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("Cart")
            .overlay(
                Group {
                    if showToast {
                        VStack {
                            Spacer()
                            Text(toastMessage)
                                .padding()
                                .background(Color.black.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .padding(.bottom, 40)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
            )
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Invalid Quantity"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

