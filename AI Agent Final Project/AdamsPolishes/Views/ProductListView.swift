//
//  ProductListView.swift
//  AdamsPolishes
//
//  Filtered product list view for categories and search results
//

import SwiftUI

struct ProductListView: View {
    let title: String
    let filterType: FilterType
    
    @StateObject private var shopifyService = ShopifyService.shared
    @StateObject private var cartManager = CartManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var filteredProducts: [Product] = []
    @State private var isLoading = true
    @State private var addedToCartProduct: String? = nil
    
    enum FilterType {
        case category(String)      // Filter by product type/collection handle
        case tag(String)           // Filter by tag
        case search(String)        // Search query
        case featured              // Featured/doorbusters
        case newArrivals           // New products
        case bestSellers           // Best selling products
        case all                   // All products
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            AppTheme.primaryBlack
                .ignoresSafeArea()
            
            if isLoading {
                loadingView
            } else if filteredProducts.isEmpty {
                emptyView
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredProducts) { product in
                            AdamsProductCard(product: product, badge: product.isOnSale ? "SALE" : nil) {
                                addProductToGarage(product)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
        }
        .overlay(alignment: .bottom) {
            // Added to Garage Toast
            if addedToCartProduct != nil {
                AddedToGarageToast()
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.8)),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                    .padding(.bottom, 100)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: addedToCartProduct != nil)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.primaryBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            filterProducts()
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(AppTheme.adamsRed)
                .scaleEffect(1.5)
            
            Text("Loading products...")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.mediumGray)
        }
    }
    
    // MARK: - Empty View
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.darkGray)
            
            Text("No products found")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text("Try a different category or check back later")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.mediumGray)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    // MARK: - Filter Products
    
    private func filterProducts() {
        isLoading = true
        
        let allProducts = shopifyService.products
        
        switch filterType {
        case .category(let handle):
            // Filter by product type or collection handle
            filteredProducts = allProducts.filter { product in
                product.productType.lowercased().contains(handle.lowercased()) ||
                product.tags.contains { $0.lowercased().contains(handle.lowercased()) }
            }
            
        case .tag(let tag):
            // Filter by specific tag
            filteredProducts = allProducts.filter { product in
                product.tags.contains { $0.lowercased().contains(tag.lowercased()) } ||
                product.productType.lowercased().contains(tag.lowercased()) ||
                product.title.lowercased().contains(tag.lowercased())
            }
            
        case .search(let query):
            // Search in title, description, tags
            let searchQuery = query.lowercased()
            filteredProducts = allProducts.filter { product in
                product.title.lowercased().contains(searchQuery) ||
                product.description.lowercased().contains(searchQuery) ||
                product.productType.lowercased().contains(searchQuery) ||
                product.tags.contains { $0.lowercased().contains(searchQuery) }
            }
            
        case .featured:
            // Featured products (first 10 or products with "featured" tag)
            filteredProducts = allProducts.filter { product in
                product.tags.contains { $0.lowercased().contains("featured") } ||
                product.tags.contains { $0.lowercased().contains("doorbuster") }
            }
            if filteredProducts.isEmpty {
                filteredProducts = Array(allProducts.prefix(10))
            }
            
        case .newArrivals:
            // New arrivals (products with "new" tag or first 10)
            filteredProducts = allProducts.filter { product in
                product.tags.contains { $0.lowercased().contains("new") }
            }
            if filteredProducts.isEmpty {
                filteredProducts = Array(allProducts.prefix(10))
            }
            
        case .bestSellers:
            // Best sellers (products with "best-seller" tag or first 10)
            filteredProducts = allProducts.filter { product in
                product.tags.contains { $0.lowercased().contains("best") || $0.lowercased().contains("popular") }
            }
            if filteredProducts.isEmpty {
                filteredProducts = Array(allProducts.prefix(10))
            }
            
        case .all:
            filteredProducts = allProducts
        }
        
        // If no products match and we have products, show all as fallback for demo
        if filteredProducts.isEmpty && !allProducts.isEmpty {
            filteredProducts = allProducts
        }
        
        isLoading = false
    }
    
    // MARK: - Add to Garage
    
    private func addProductToGarage(_ product: Product) {
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        cartManager.addToCart(product)
        
        withAnimation {
            addedToCartProduct = product.id
        }
        
        // Success haptic
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                if addedToCartProduct == product.id {
                    addedToCartProduct = nil
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ProductListView(title: "Interior", filterType: .category("interior"))
    }
}

