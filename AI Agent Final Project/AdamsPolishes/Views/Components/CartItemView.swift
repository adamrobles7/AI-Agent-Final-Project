//
//  CartItemView.swift
//  AdamsPolishes
//
//  Individual cart item row for My Garage
//

import SwiftUI

struct CartItemView: View {
    let item: CartItem
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Product Image
            AsyncImage(url: URL(string: item.imageURL ?? "")) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.charcoal)
                        .overlay(
                            ProgressView()
                                .tint(AppTheme.accentRed)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                case .failure:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.charcoal)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundColor(AppTheme.mediumGray)
                        )
                @unknown default:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.charcoal)
                }
            }
            .frame(width: 90, height: 90)
            
            // Product Info
            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                if let variantTitle = item.variantTitle {
                    Text(variantTitle)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.mediumGray)
                }
                
                HStack(spacing: 8) {
                    Text("$\(String(format: "%.2f", item.price))")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.accentRed)
                    
                    if let comparePrice = item.compareAtPrice, comparePrice > item.price {
                        Text("$\(String(format: "%.2f", comparePrice))")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.mediumGray)
                            .strikethrough()
                    }
                }
                
                // Quantity Controls
                HStack(spacing: 0) {
                    Button(action: onDecrement) {
                        Image(systemName: item.quantity == 1 ? "trash" : "minus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(item.quantity == 1 ? AppTheme.accentRed : .white)
                            .frame(width: 32, height: 32)
                            .background(AppTheme.charcoal)
                    }
                    
                    Text("\(item.quantity)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 32)
                        .background(AppTheme.richBlack)
                    
                    Button(action: onIncrement) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(AppTheme.charcoal)
                    }
                }
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.charcoal, lineWidth: 1)
                )
            }
            
            Spacer()
            
            // Item Subtotal
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.2f", item.subtotal))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                if item.savings > 0 {
                    Text("-$\(String(format: "%.2f", item.savings))")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.accentRed)
                }
            }
        }
        .padding(16)
        .background(AppTheme.cardGradient)
        .cornerRadius(16)
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Swipe to Delete Wrapper

struct SwipeableCartItemView: View {
    let item: CartItem
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onRemove: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var showingDelete = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete Background
            HStack {
                Spacer()
                
                Button(action: onRemove) {
                    VStack(spacing: 4) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 20))
                        Text("Remove")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(width: 80)
                }
            }
            .frame(maxHeight: .infinity)
            .background(AppTheme.accentRed)
            .cornerRadius(16)
            
            // Cart Item
            CartItemView(
                item: item,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
                onRemove: onRemove
            )
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = max(value.translation.width, -80)
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring()) {
                            if value.translation.width < -40 {
                                offset = -80
                                showingDelete = true
                            } else {
                                offset = 0
                                showingDelete = false
                            }
                        }
                    }
            )
            .onTapGesture {
                if showingDelete {
                    withAnimation(.spring()) {
                        offset = 0
                        showingDelete = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        CartItemView(
            item: CartItem(
                id: "1",
                productId: "prod-1",
                variantId: "var-1",
                title: "Premium Car Wax",
                variantTitle: "16 oz",
                price: 24.99,
                compareAtPrice: 29.99,
                imageURL: nil,
                quantity: 2
            ),
            onIncrement: {},
            onDecrement: {},
            onRemove: {}
        )
    }
    .padding()
    .background(AppTheme.primaryBlack)
}

