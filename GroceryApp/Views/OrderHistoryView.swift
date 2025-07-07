//
//  Untitled.swift
//  GroceryApp
//
//  Created by Dungeon_master on 01/07/25.
//

import SwiftUI

struct OrderHistoryView: View {
    @ObservedObject var viewModel: GroceryViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.orderHistory.isEmpty {
                    EmptyOrderView()
                } else {
                    VStack(spacing: 16) {
                        ForEach(viewModel.orderHistory.reversed()) { order in
                            OrderCardView(order: order)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("🧾 Order History")
        }
    }
}

struct EmptyOrderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundColor(.gray.opacity(0.5))

            Text("No Orders Yet")
                .font(.title2)
                .foregroundColor(.gray)

            Text("Your past orders will appear here after checkout.")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.top, 80)
        .frame(maxWidth: .infinity)
    }
}

struct OrderCardView: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Label {
                    Text(order.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.headline)
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                }

                Spacer()

                Text("ID: \(order.id.uuidString.prefix(6))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            // Items
            ForEach(order.items) { item in
                OrderItemRow(item: item)
            }

            Divider()

            // Totals
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
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct OrderItemRow: View {
    let item: OrderItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.name)
                    .fontWeight(.medium)
                Spacer()
                Text("x\(item.quantity)")
            }

            HStack {
                Text("\(item.weightLabel) @ ₹\(item.pricePerKg.clean)/kg")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("₹\(item.totalPrice.clean)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
