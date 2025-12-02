//
//  CategoryDetailView.swift
//  AdamsPolishes
//
//  Category detail page with sub-category filters
//

import SwiftUI

struct CategoryDetailView: View {
    let category: ShopCategory
    
    @StateObject private var shopifyService = ShopifyService.shared
    @StateObject private var cartManager = CartManager.shared
    @State private var selectedSubCategory: SubCategory? = nil
    @State private var filteredProducts: [Product] = []
    @State private var addedToCartProduct: String? = nil
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            AppTheme.primaryBlack
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Sub-category filters
                subCategoryFilters
                
                // Products grid
                if filteredProducts.isEmpty {
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
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.primaryBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(category.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    if !filteredProducts.isEmpty {
                        Text("\(filteredProducts.count) product\(filteredProducts.count == 1 ? "" : "s")")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.mediumGray)
                    }
                }
            }
        }
        .onAppear {
            filterProducts()
        }
        .onChange(of: selectedSubCategory) { _, _ in
            filterProducts()
        }
    }
    
    // MARK: - Sub-category Filters
    
    private var subCategoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // "All" button
                FilterChip(
                    title: "All",
                    isSelected: selectedSubCategory == nil
                ) {
                    selectedSubCategory = nil
                }
                
                // Sub-category buttons
                ForEach(category.subCategories) { subCategory in
                    FilterChip(
                        title: subCategory.title,
                        isSelected: selectedSubCategory?.id == subCategory.id
                    ) {
                        selectedSubCategory = subCategory
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(AppTheme.richBlack)
    }
    
    // MARK: - Empty View
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.darkGray)
            
            Text("No products found")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            if let subCategory = selectedSubCategory {
                Text("No products tagged with '\(subCategory.tag)'")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.mediumGray)
            } else {
                Text("No products in \(category.title)")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.mediumGray)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Filter Products
    
    private func filterProducts() {
        let allProducts = shopifyService.products
        
        if let subCategory = selectedSubCategory {
            // Filter by EXACT sub-category tag match only
            // Product must have the exact tag (case-insensitive)
            filteredProducts = allProducts.filter { product in
                product.tags.contains { tag in
                    // Exact match (case-insensitive)
                    tag.lowercased() == subCategory.tag.lowercased() ||
                    // Or tag equals the sub-category title
                    tag.lowercased() == subCategory.title.lowercased()
                } ||
                // Or product type exactly matches
                product.productType.lowercased() == subCategory.tag.lowercased() ||
                product.productType.lowercased() == subCategory.title.lowercased()
            }
        } else {
            // Filter by main category tag
            filteredProducts = allProducts.filter { product in
                product.tags.contains { tag in
                    tag.lowercased() == category.handle.lowercased() ||
                    tag.lowercased().contains(category.handle.lowercased())
                } ||
                product.productType.lowercased().contains(category.handle.lowercased())
            }
        }
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

// MARK: - Filter Chip Component

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            UISelectionFeedbackGenerator().selectionChanged()
            action()
        }) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .white : AppTheme.mediumGray)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? AppTheme.adamsRed : AppTheme.charcoal)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? AppTheme.adamsRed : AppTheme.darkGray, lineWidth: 1)
                )
        }
    }
}

// MARK: - Sub-category Model

struct SubCategory: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let tag: String
    
    static func == (lhs: SubCategory, rhs: SubCategory) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CategoryDetailView(category: ShopCategory.categories[1]) // Exterior
    }
}

