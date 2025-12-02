//
//  Product.swift
//  AdamsPolishes
//
//  Product model matching Shopify API structure
//

import Foundation

struct Product: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let descriptionHtml: String
    let vendor: String
    let productType: String
    let tags: [String]
    let variants: [ProductVariant]
    let images: [ProductImage]
    
    var price: String {
        variants.first?.price ?? "0.00"
    }
    
    var compareAtPrice: String? {
        variants.first?.compareAtPrice
    }
    
    var featuredImage: String? {
        // Use the url property which handles URL formatting
        return images.first?.url
    }
    
    var isOnSale: Bool {
        if let compare = compareAtPrice, let compareValue = Double(compare),
           let priceValue = Double(price) {
            return compareValue > priceValue
        }
        return false
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }
}

struct ProductVariant: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let price: String
    let compareAtPrice: String?
    let sku: String?
    let availableForSale: Bool
    let quantityAvailable: Int?
}

struct ProductImage: Identifiable, Codable, Hashable {
    let id: String
    let src: String
    let altText: String?
    
    /// Returns the properly formatted URL for the image
    var url: String {
        // Some Shopify URLs might start with // instead of https://
        if src.hasPrefix("//") {
            return "https:" + src
        }
        return src
    }
}

// MARK: - Shopify API Response Models

struct ShopifyProductsResponse: Codable {
    let data: ShopifyData
}

struct ShopifyData: Codable {
    let products: ShopifyProductConnection
}

struct ShopifyProductConnection: Codable {
    let edges: [ShopifyProductEdge]
    let pageInfo: PageInfo
}

struct ShopifyProductEdge: Codable {
    let node: ShopifyProductNode
    let cursor: String
}

struct ShopifyProductNode: Codable {
    let id: String
    let title: String
    let description: String
    let descriptionHtml: String
    let vendor: String
    let productType: String
    let tags: [String]
    let variants: ShopifyVariantConnection
    let images: ShopifyImageConnection
}

struct ShopifyVariantConnection: Codable {
    let edges: [ShopifyVariantEdge]
}

struct ShopifyVariantEdge: Codable {
    let node: ShopifyVariantNode
}

struct ShopifyVariantNode: Codable {
    let id: String
    let title: String
    let priceV2: ShopifyPrice
    let compareAtPriceV2: ShopifyPrice?
    let sku: String?
    let availableForSale: Bool
    let quantityAvailable: Int?
}

struct ShopifyPrice: Codable {
    let amount: String
    let currencyCode: String
}

struct ShopifyImageConnection: Codable {
    let edges: [ShopifyImageEdge]
}

struct ShopifyImageEdge: Codable {
    let node: ShopifyImageNode
}

struct ShopifyImageNode: Codable {
    let id: String
    let url: String
    let altText: String?
}

struct PageInfo: Codable {
    let hasNextPage: Bool
    let endCursor: String?
}

// MARK: - Collection Model

struct ProductCollection: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let image: ProductImage?
}

