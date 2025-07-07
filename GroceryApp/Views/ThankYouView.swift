//
//  ThankYouView.swift
//  GroceryApp
//
//  Created by Dungeon_master on 01/07/25.
//

import SwiftUI

struct ThankYouView: View {
    @Environment(\.dismiss) var dismiss
    @State private var animate = false

    var order: GroceryOrder?

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // MARK: - Animated Emoji
                Text("🎉")
                    .font(.system(size: 80))
                    .scaleEffect(animate ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: animate)

                // MARK: - Thank You Text
                VStack(spacing: 10) {
                    Text("Thank You!")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Your order has been placed successfully.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("We hope to see you again soon.")
                        .foregroundColor(.gray)
                }

                Divider()

                // MARK: - Order Summary
                if let order = order {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🧾 Order Summary")
                            .font(.headline)

                        ForEach(order.items) { item in
                            HStack {
                                Text(item.name)
                                Spacer()
                                Text("x\(item.quantity)")
                                Text("₹\(item.totalPrice.clean)")
                                    .foregroundColor(.secondary)
                            }
                            .font(.subheadline)
                        }

                        Divider()

                        HStack {
                            Text("Total Weight:")
                            Spacer()
                            Text("\((order.totalWeight / 1000).clean) kg")
                                .fontWeight(.semibold)
                        }

                        HStack {
                            Text("Grand Total:")
                            Spacer()
                            Text("₹\(order.total.clean)")
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                }

                // MARK: - Continue Shopping Button
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    dismiss()
                }) {
                    Label("Continue Shopping", systemImage: "arrow.right.circle.fill")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 30)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            animate = true
        }
        .navigationBarBackButtonHidden(true)
    }
}
