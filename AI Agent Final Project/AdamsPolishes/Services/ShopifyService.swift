//
//  ShopifyService.swift
//  AdamsPolishes
//
//  Shopify Storefront API integration service
//

import Foundation

class ShopifyService: ObservableObject {
    
    // MARK: - Configuration
    private let shopDomain = "test-store-project-56.myshopify.com"
    private let storefrontAccessToken = "04441fa45bc4d347bd7f634c86e6d5cd"
    
    private var apiURL: URL {
        URL(string: "https://\(shopDomain)/api/2024-01/graphql.json")!
    }
    
    // MARK: - Published Properties
    @Published var products: [Product] = []
    @Published var featuredProducts: [Product] = []
    @Published var doorbusterProducts: [Product] = []
    @Published var bestSellerProducts: [Product] = []
    @Published var newArrivalProducts: [Product] = []
    @Published var collections: [ProductCollection] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    // MARK: - Singleton
    static let shared = ShopifyService()
    
    private init() {}
    
    // MARK: - API Methods
    
    /// Fetch all products from the store
    func fetchProducts(first: Int = 20, after: String? = nil) async throws -> [Product] {
        let query = """
        {
            products(first: \(first)\(after != nil ? ", after: \"\(after!)\"" : "")) {
                edges {
                    node {
                        id
                        title
                        description
                        descriptionHtml
                        vendor
                        productType
                        tags
                        variants(first: 10) {
                            edges {
                                node {
                                    id
                                    title
                                    priceV2 {
                                        amount
                                        currencyCode
                                    }
                                    compareAtPriceV2 {
                                        amount
                                        currencyCode
                                    }
                                    sku
                                    availableForSale
                                    quantityAvailable
                                }
                            }
                        }
                        images(first: 5) {
                            edges {
                                node {
                                    id
                                    url
                                    altText
                                }
                            }
                        }
                    }
                    cursor
                }
                pageInfo {
                    hasNextPage
                    endCursor
                }
            }
        }
        """
        
        let response: ShopifyProductsResponse = try await executeQuery(query)
        return mapProducts(from: response)
    }
    
    /// Fetch products by collection handle
    func fetchProductsByCollection(handle: String, first: Int = 20) async throws -> [Product] {
        let query = """
        {
            collection(handle: "\(handle)") {
                products(first: \(first)) {
                    edges {
                        node {
                            id
                            title
                            description
                            descriptionHtml
                            vendor
                            productType
                            tags
                            variants(first: 10) {
                                edges {
                                    node {
                                        id
                                        title
                                        priceV2 {
                                            amount
                                            currencyCode
                                        }
                                        compareAtPriceV2 {
                                            amount
                                            currencyCode
                                        }
                                        sku
                                        availableForSale
                                        quantityAvailable
                                    }
                                }
                            }
                            images(first: 5) {
                                edges {
                                    node {
                                        id
                                        url
                                        altText
                                    }
                                }
                            }
                        }
                        cursor
                    }
                    pageInfo {
                        hasNextPage
                        endCursor
                    }
                }
            }
        }
        """
        
        _ = try await executeRawQuery(query)
        // Parse collection-specific response
        // Implementation depends on your specific needs
        return []
    }
    
    /// Search products by keyword
    func searchProducts(query searchQuery: String, first: Int = 20) async throws -> [Product] {
        let query = """
        {
            products(first: \(first), query: "\(searchQuery)") {
                edges {
                    node {
                        id
                        title
                        description
                        descriptionHtml
                        vendor
                        productType
                        tags
                        variants(first: 10) {
                            edges {
                                node {
                                    id
                                    title
                                    priceV2 {
                                        amount
                                        currencyCode
                                    }
                                    compareAtPriceV2 {
                                        amount
                                        currencyCode
                                    }
                                    sku
                                    availableForSale
                                    quantityAvailable
                                }
                            }
                        }
                        images(first: 5) {
                            edges {
                                node {
                                    id
                                    url
                                    altText
                                }
                            }
                        }
                    }
                    cursor
                }
                pageInfo {
                    hasNextPage
                    endCursor
                }
            }
        }
        """
        
        let response: ShopifyProductsResponse = try await executeQuery(query)
        return mapProducts(from: response)
    }
    
    // MARK: - Private Methods
    
    private func executeQuery<T: Codable>(_ query: String) async throws -> T {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(storefrontAccessToken, forHTTPHeaderField: "X-Shopify-Storefront-Access-Token")
        
        let body = ["query": query]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ShopifyError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    private func executeRawQuery(_ query: String) async throws -> Data {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(storefrontAccessToken, forHTTPHeaderField: "X-Shopify-Storefront-Access-Token")
        
        let body = ["query": query]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ShopifyError.invalidResponse
        }
        
        return data
    }
    
    private func mapProducts(from response: ShopifyProductsResponse) -> [Product] {
        return response.data.products.edges.map { edge in
            let node = edge.node
            
            let variants = node.variants.edges.map { variantEdge -> ProductVariant in
                let v = variantEdge.node
                return ProductVariant(
                    id: v.id,
                    title: v.title,
                    price: v.priceV2.amount,
                    compareAtPrice: v.compareAtPriceV2?.amount,
                    sku: v.sku,
                    availableForSale: v.availableForSale,
                    quantityAvailable: v.quantityAvailable
                )
            }
            
            let images = node.images.edges.map { imageEdge -> ProductImage in
                let i = imageEdge.node
                return ProductImage(
                    id: i.id,
                    src: i.url,
                    altText: i.altText
                )
            }
            
            return Product(
                id: node.id,
                title: node.title,
                description: node.description,
                descriptionHtml: node.descriptionHtml,
                vendor: node.vendor,
                productType: node.productType,
                tags: node.tags,
                variants: variants,
                images: images
            )
        }
    }
    
    // MARK: - Load Products (Main Entry Point)
    
    @MainActor
    func loadProducts() async {
        isLoading = true
        error = nil
        
        do {
            products = try await fetchProducts()
            
            // Filter products by specific tags
            doorbusterProducts = products.filter { product in
                product.tags.contains { tag in
                    let lowercased = tag.lowercased()
                    return lowercased.contains("doorbuster") || 
                           lowercased.contains("door buster") ||
                           lowercased.contains("deal")
                }
            }
            
            bestSellerProducts = products.filter { product in
                product.tags.contains { tag in
                    let lowercased = tag.lowercased()
                    return lowercased.contains("best seller") || 
                           lowercased.contains("bestseller") ||
                           lowercased.contains("best-seller") ||
                           lowercased.contains("popular") ||
                           lowercased.contains("top rated")
                }
            }
            
            newArrivalProducts = products.filter { product in
                product.tags.contains { tag in
                    let lowercased = tag.lowercased()
                    return lowercased.contains("new") || 
                           lowercased.contains("new arrival") ||
                           lowercased.contains("new-arrival") ||
                           lowercased.contains("just in")
                }
            }
            
            // Featured products - combine doorbusters and best sellers, or use first 6 as fallback
            if !doorbusterProducts.isEmpty || !bestSellerProducts.isEmpty {
                featuredProducts = Array((doorbusterProducts + bestSellerProducts).prefix(6))
            } else {
                featuredProducts = Array(products.prefix(6))
            }
            
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}

// MARK: - Errors

enum ShopifyError: Error, LocalizedError {
    case invalidResponse
    case decodingError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}

