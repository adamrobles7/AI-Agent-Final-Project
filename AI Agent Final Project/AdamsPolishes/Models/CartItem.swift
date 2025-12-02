//
//  CartItem.swift
//  AdamsPolishes
//
//  Cart item model for My Garage shopping cart
//

import Foundation

struct CartItem: Identifiable, Codable, Equatable {
    let id: String
    let productId: String
    let variantId: String
    let title: String
    let variantTitle: String?
    let price: Double
    let compareAtPrice: Double?
    let imageURL: String?
    var quantity: Int
    
    var subtotal: Double {
        price * Double(quantity)
    }
    
    var savings: Double {
        guard let comparePrice = compareAtPrice else { return 0 }
        return (comparePrice - price) * Double(quantity)
    }
    
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        lhs.id == rhs.id && lhs.quantity == rhs.quantity
    }
}

// MARK: - Create CartItem from Product

extension CartItem {
    init(from product: Product, variant: ProductVariant? = nil) {
        let selectedVariant = variant ?? product.variants.first!
        
        self.id = UUID().uuidString
        self.productId = product.id
        self.variantId = selectedVariant.id
        self.title = product.title
        self.variantTitle = selectedVariant.title != "Default Title" ? selectedVariant.title : nil
        self.price = Double(selectedVariant.price) ?? 0
        self.compareAtPrice = selectedVariant.compareAtPrice.flatMap { Double($0) }
        self.imageURL = product.featuredImage
        self.quantity = 1
    }
}

