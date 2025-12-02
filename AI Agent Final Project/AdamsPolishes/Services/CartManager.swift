//
//  CartManager.swift
//  AdamsPolishes
//
//  Cart state management for My Garage
//

import Foundation
import SwiftUI

class CartManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var items: [CartItem] = []
    @Published var isCheckingOut = false
    @Published var promoCode: String = ""
    @Published var promoDiscount: Double = 0
    
    // MARK: - Singleton
    static let shared = CartManager()
    
    private let cartKey = "adamsPolishes_cart"
    
    private init() {
        loadCart()
    }
    
    // MARK: - Computed Properties
    
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var subtotal: Double {
        items.reduce(0) { $0 + $1.subtotal }
    }
    
    var totalSavings: Double {
        items.reduce(0) { $0 + $1.savings } + promoDiscount
    }
    
    var estimatedTax: Double {
        subtotal * 0.0825 // 8.25% tax rate - adjust as needed
    }
    
    var estimatedShipping: Double {
        subtotal >= 75 ? 0 : 7.99 // Free shipping over $75
    }
    
    var total: Double {
        subtotal + estimatedTax + estimatedShipping - promoDiscount
    }
    
    var isEmpty: Bool {
        items.isEmpty
    }
    
    var freeShippingProgress: Double {
        min(subtotal / 75.0, 1.0)
    }
    
    var amountToFreeShipping: Double {
        max(75 - subtotal, 0)
    }
    
    // MARK: - Cart Actions
    
    func addToCart(_ product: Product, variant: ProductVariant? = nil) {
        let selectedVariant = variant ?? product.variants.first!
        
        // Check if item already exists in cart
        if let index = items.firstIndex(where: { $0.variantId == selectedVariant.id }) {
            items[index].quantity += 1
        } else {
            let newItem = CartItem(from: product, variant: variant)
            items.append(newItem)
        }
        
        saveCart()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func removeFromCart(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
        saveCart()
    }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        
        if quantity <= 0 {
            items.remove(at: index)
        } else {
            items[index].quantity = quantity
        }
        
        saveCart()
    }
    
    func incrementQuantity(for item: CartItem) {
        updateQuantity(for: item, quantity: item.quantity + 1)
    }
    
    func decrementQuantity(for item: CartItem) {
        updateQuantity(for: item, quantity: item.quantity - 1)
    }
    
    func clearCart() {
        items.removeAll()
        promoCode = ""
        promoDiscount = 0
        saveCart()
    }
    
    func applyPromoCode(_ code: String) {
        // TODO: Validate promo code with Shopify API
        // For now, simple demo codes
        promoCode = code.uppercased()
        
        switch promoCode {
        case "SHINE10":
            promoDiscount = subtotal * 0.10
        case "GARAGE20":
            promoDiscount = subtotal * 0.20
        case "FIRST15":
            promoDiscount = subtotal * 0.15
        default:
            promoDiscount = 0
        }
    }
    
    // MARK: - Persistence
    
    private func saveCart() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: cartKey)
        }
    }
    
    private func loadCart() {
        if let data = UserDefaults.standard.data(forKey: cartKey),
           let decoded = try? JSONDecoder().decode([CartItem].self, from: data) {
            items = decoded
        }
    }
    
    // MARK: - Checkout
    
    func initiateCheckout() async throws -> URL {
        isCheckingOut = true
        
        // TODO: Create Shopify checkout via Storefront API
        // This would create a checkout and return the webURL
        
        // Placeholder - replace with actual Shopify checkout creation
        let checkoutURL = URL(string: "https://your-store.myshopify.com/checkout")!
        
        isCheckingOut = false
        return checkoutURL
    }
}

