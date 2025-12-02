//
//  MyGarageView.swift
//  AdamsPolishes
//
//  My Garage - Shopping cart styled like adamspolishes.com
//

import SwiftUI

struct MyGarageView: View {
    @StateObject private var cartManager = CartManager.shared
    @State private var promoCodeInput = ""
    @State private var showingPromoField = false
    @State private var showingCheckout = false
    @State private var showingCheckoutAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Pure black background
                AppTheme.primaryBlack
                    .ignoresSafeArea()
                
                if cartManager.isEmpty {
                    emptyGarageView
                } else {
                    filledGarageView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("My Garage")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !cartManager.isEmpty {
                        Button(action: {
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                            cartManager.clearCart()
                        }) {
                            Text("Clear")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.adamsRed)
                        }
                    }
                }
            }
            .toolbarBackground(AppTheme.primaryBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    // MARK: - Empty Garage View
    
    private var emptyGarageView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Empty cart icon with animation
            ZStack {
                Circle()
                    .fill(AppTheme.charcoal)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "cart")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(AppTheme.mediumGray)
            }
            
            VStack(spacing: 12) {
                Text("Your Garage is Empty")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Add products to your garage while\nshopping to prepare for checkout")
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.mediumGray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            // Navigate to Shop tab hint
            VStack(spacing: 8) {
                Image(systemName: "arrow.down")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.adamsRed)
                
                Text("Tap 'Shop' below to browse products")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.adamsRed)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Filled Garage View
    
    private var filledGarageView: some View {
        VStack(spacing: 0) {
            // Free Shipping Progress
            freeShippingBanner
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    // Cart Items
                    ForEach(cartManager.items) { item in
                        AdamsCartItemView(
                            item: item,
                            onIncrement: { 
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                cartManager.incrementQuantity(for: item) 
                            },
                            onDecrement: { 
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                cartManager.decrementQuantity(for: item) 
                            },
                            onRemove: { 
                                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                                cartManager.removeFromCart(item) 
                            }
                        )
                    }
                    
                    // Promo Code Section
                    promoCodeSection
                    
                    // Order Summary
                    orderSummarySection
                    
                    // Checkout Button
                    checkoutButton
                    
                    // Add Note Section
                    addNoteSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
        }
    }
    
    // MARK: - Free Shipping Banner
    
    private var freeShippingBanner: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: cartManager.estimatedShipping == 0 ? "checkmark.circle.fill" : "shippingbox")
                    .foregroundColor(cartManager.estimatedShipping == 0 ? AppTheme.successGreen : .white)
                
                if cartManager.estimatedShipping == 0 {
                    Text("You've unlocked FREE shipping!")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.successGreen)
                        .lineLimit(1)
                } else {
                    Text("Add $\(String(format: "%.2f", cartManager.amountToFreeShipping)) for FREE shipping")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppTheme.darkGray)
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(cartManager.estimatedShipping == 0 ? AppTheme.successGreen : AppTheme.adamsRed)
                        .frame(width: geo.size.width * cartManager.freeShippingProgress, height: 4)
                        .animation(.easeOut(duration: 0.3), value: cartManager.freeShippingProgress)
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(AppTheme.charcoal)
    }
    
    // MARK: - Promo Code Section
    
    private var promoCodeSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showingPromoField.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "tag")
                        .foregroundColor(.white)
                    
                    Text(cartManager.promoCode.isEmpty ? "Add promo code" : "Code: \(cartManager.promoCode)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: showingPromoField ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.mediumGray)
                }
                .padding(16)
                .background(AppTheme.charcoal)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(AppTheme.darkGray, lineWidth: 1)
                )
                .cornerRadius(4)
            }
            
            if showingPromoField {
                HStack(spacing: 12) {
                    TextField("Enter code", text: $promoCodeInput)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .accentColor(AppTheme.adamsRed)
                        .textInputAutocapitalization(.characters)
                        .padding(14)
                        .background(AppTheme.richBlack)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(AppTheme.darkGray, lineWidth: 1)
                        )
                        .cornerRadius(4)
                    
                    Button(action: {
                        cartManager.applyPromoCode(promoCodeInput)
                        withAnimation {
                            showingPromoField = false
                        }
                    }) {
                        Text("Apply")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(AppTheme.adamsRed)
                            .cornerRadius(4)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    // MARK: - Order Summary Section
    
    private var orderSummarySection: some View {
        VStack(spacing: 14) {
            // Line Items
            VStack(spacing: 10) {
                summaryRow(title: "Subtotal", value: "$\(String(format: "%.2f", cartManager.subtotal))")
                
                if cartManager.promoDiscount > 0 {
                    summaryRow(
                        title: "Discount",
                        value: "-$\(String(format: "%.2f", cartManager.promoDiscount))",
                        valueColor: AppTheme.successGreen
                    )
                }
                
                summaryRow(
                    title: "Shipping",
                    value: cartManager.estimatedShipping == 0 ? "FREE" : "$\(String(format: "%.2f", cartManager.estimatedShipping))",
                    valueColor: cartManager.estimatedShipping == 0 ? AppTheme.successGreen : .white
                )
                
                summaryRow(title: "Estimated Tax", value: "$\(String(format: "%.2f", cartManager.estimatedTax))")
            }
            
            // Divider
            Rectangle()
                .fill(AppTheme.darkGray)
                .frame(height: 1)
            
            // Total
            HStack {
                Text("Total")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("$\(String(format: "%.2f", cartManager.total))")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(.white)
            }
            
            // Savings Callout
            if cartManager.totalSavings > 0 {
                HStack {
                    Text("You're saving $\(String(format: "%.2f", cartManager.totalSavings))!")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.adamsRed)
                        .lineLimit(1)
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(AppTheme.charcoal)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(AppTheme.darkGray, lineWidth: 1)
        )
        .cornerRadius(4)
    }
    
    private func summaryRow(title: String, value: String, valueColor: Color = .white) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.mediumGray)
                .lineLimit(1)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(valueColor)
                .lineLimit(1)
        }
    }
    
    // MARK: - Checkout Button
    
    private var checkoutButton: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            showingCheckoutAlert = true
        }) {
            HStack {
                if cartManager.isCheckingOut {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14))
                    Text("Checkout • $\(String(format: "%.2f", cartManager.total))")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.adamsRed)
            .cornerRadius(4)
        }
        .disabled(cartManager.isCheckingOut)
        .alert("Checkout", isPresented: $showingCheckoutAlert) {
            Button("Continue Shopping", role: .cancel) { }
            Button("Complete Demo Order") {
                // Simulate order completion
                cartManager.clearCart()
            }
        } message: {
            Text("This is a demo checkout. In production, this would redirect to Shopify's secure checkout.\n\nTotal: $\(String(format: "%.2f", cartManager.total))")
        }
    }
    
    // MARK: - Add Note Section
    
    private var addNoteSection: some View {
        VStack(spacing: 16) {
            Button(action: {}) {
                HStack {
                    Image(systemName: "note.text")
                        .foregroundColor(AppTheme.mediumGray)
                    Text("Add order note")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.mediumGray)
                    Spacer()
                }
            }
            
            // Security & Payment Info
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(AppTheme.mediumGray)
                    Text("Secure checkout")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.mediumGray)
                    Spacer()
                }
                
                Text("We accept all major credit cards and PayPal")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.mediumGray)
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Adam's Style Cart Item View

struct AdamsCartItemView: View {
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
                    Rectangle()
                        .fill(AppTheme.charcoal)
                        .overlay(
                            ProgressView()
                                .tint(AppTheme.adamsRed)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                case .failure:
                    Rectangle()
                        .fill(AppTheme.charcoal)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.mediumGray)
                        )
                @unknown default:
                    Rectangle()
                        .fill(AppTheme.charcoal)
                }
            }
            .frame(width: 80, height: 80)
            .clipped()
            .cornerRadius(4)
            
            // Product Info
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if let variantTitle = item.variantTitle {
                    Text(variantTitle)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.mediumGray)
                }
                
                HStack(spacing: 6) {
                    Text("$\(String(format: "%.2f", item.price))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    if let comparePrice = item.compareAtPrice, comparePrice > item.price {
                        Text("$\(String(format: "%.2f", comparePrice))")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.mediumGray)
                            .strikethrough()
                            .lineLimit(1)
                    }
                }
                
                // Quantity Controls
                HStack(spacing: 0) {
                    Button(action: onDecrement) {
                        Image(systemName: item.quantity == 1 ? "trash" : "minus")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(item.quantity == 1 ? AppTheme.adamsRed : .white)
                            .frame(width: 32, height: 32)
                            .background(AppTheme.darkGray)
                    }
                    
                    Text("\(item.quantity)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 32)
                        .background(AppTheme.charcoal)
                    
                    Button(action: onIncrement) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(AppTheme.darkGray)
                    }
                }
                .cornerRadius(4)
            }
            
            Spacer()
            
            // Item Subtotal & Remove
            VStack(alignment: .trailing, spacing: 8) {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.mediumGray)
                }
                
                Spacer()
                
                Text("$\(String(format: "%.2f", item.subtotal))")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(16)
        .background(AppTheme.charcoal)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(AppTheme.darkGray, lineWidth: 1)
        )
        .cornerRadius(4)
    }
}

// MARK: - Preview

#Preview {
    MyGarageView()
}
