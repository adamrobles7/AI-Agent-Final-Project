//
//  ShopView.swift
//  AdamsPolishes
//
//  Shop storefront - matching adamspolishes.com style
//

import SwiftUI

struct ShopView: View {
    @StateObject private var shopifyService = ShopifyService.shared
    @StateObject private var cartManager = CartManager.shared
    @State private var searchText = ""
    @State private var showingSearch = false
    @State private var addedToCartProduct: String? = nil
    @State private var currentPromoIndex = 0
    @State private var navigateToSearch = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    // Promo banners like the website
    private let promoBanners: [(title: String, subtitle: String, buttonText: String, filterType: ProductListView.FilterType)] = [
        ("Black Friday Sale", "Our Biggest Sale Of The Year Is Here!", "SHOP NOW", .featured),
        ("Gift Shopping", "Check Out Our Favorite Gift Ideas!", "SHOP NOW", .tag("gift")),
        ("Shop Doorbusters", "Shop Our Best Deals This Season!", "SHOP NOW", .featured),
        ("Best Sellers", "Not Sure What to Grab? Let Us Help", "SHOP NOW", .bestSellers)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Pure black background like the website
                AppTheme.primaryBlack
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Announcement Bar
                        announcementBar
                        
                        // Header with Logo & Cart
                        headerSection
                        
                        // Search Bar
                        searchBar
                            .padding(.top, 16)
                        
                        // Hero Promo Banner
                        heroPromoBanner
                            .padding(.top, 20)
                        
                        // Main Content
                        VStack(spacing: 32) {
                            // Categories
                            categoriesSection
                            
                            // Doorbusters Section
                            doorbustersSection
                            
                            // New Products
                            newProductsSection
                            
                            // Best Sellers
                            bestSellersSection
                            
                            // Trust Badges
                            trustBadgesSection
                        }
                        .padding(.top, 28)
                        .padding(.bottom, 120)
                    }
                }
                .refreshable {
                    await shopifyService.loadProducts()
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToSearch) {
                ProductListView(title: "Search: \(searchText)", filterType: .search(searchText))
            }
            .overlay {
                // Loading overlay for initial load
                if shopifyService.isLoading && shopifyService.products.isEmpty {
                    ZStack {
                        AppTheme.primaryBlack.opacity(0.9)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.adamsRed))
                                .scaleEffect(1.5)
                            
                            Text("Loading Products...")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
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
        }
        .task {
            if shopifyService.products.isEmpty {
                await shopifyService.loadProducts()
            }
        }
    }
    
    // MARK: - Announcement Bar (Like website top banner)
    
    private var announcementBar: some View {
        NavigationLink(destination: ProductListView(title: "Sale", filterType: .featured)) {
            HStack(spacing: 4) {
                Spacer()
                Text("Black Friday Sale Is Here")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text("|")
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal, 4)
                Text("SHOP NOW")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .underline()
                Spacer()
            }
            .padding(.vertical, 10)
            .background(AppTheme.adamsRed)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack(alignment: .center) {
            // Logo
            Text("Adam's Polishes")
                .font(.system(size: 28, weight: .black))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.mediumGray)
            
            TextField("Search", text: $searchText)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .accentColor(AppTheme.adamsRed)
                .onSubmit {
                    if !searchText.isEmpty {
                        navigateToSearch = true
                    }
                }
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.mediumGray)
                }
                
                Button(action: {
                    navigateToSearch = true
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.adamsRed)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(AppTheme.charcoal)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(AppTheme.darkGray, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Hero Promo Banner
    
    private var heroPromoBanner: some View {
        TabView(selection: $currentPromoIndex) {
            ForEach(0..<promoBanners.count, id: \.self) { index in
                ZStack {
                    // Background with gradient
                    LinearGradient(
                        colors: [AppTheme.charcoal, AppTheme.richBlack],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Red accent glow
                    Circle()
                        .fill(AppTheme.adamsRed.opacity(0.15))
                        .frame(width: 300, height: 300)
                        .blur(radius: 80)
                        .offset(x: 100, y: -50)
                    
                    VStack(spacing: 16) {
                        Text(promoBanners[index].title)
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(promoBanners[index].subtitle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.lightGray)
                            .multilineTextAlignment(.center)
                        
                        NavigationLink(destination: ProductListView(
                            title: promoBanners[index].title,
                            filterType: promoBanners[index].filterType
                        )) {
                            Text(promoBanners[index].buttonText)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 16)
                                .background(AppTheme.adamsRed)
                        }
                        .padding(.top, 8)
                    }
                    .padding(32)
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 240)
        .padding(.horizontal, 20)
        .cornerRadius(0)
    }
    
    // MARK: - Categories Section
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ShopCategory.categories) { category in
                        NavigationLink(destination: CategoryDetailView(category: category)) {
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.charcoal)
                                        .frame(width: 56, height: 56)
                                    
                                    Image(systemName: category.iconName)
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                }
                                
                                Text(category.title)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .frame(width: 70)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Doorbusters Section
    
    private var doorbustersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "DOORBUSTERS", filterType: .tag("doorbuster"))
            
            if shopifyService.isLoading {
                loadingView
            } else if shopifyService.doorbusterProducts.isEmpty {
                emptyTagSection(message: "No doorbusters available")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(shopifyService.doorbusterProducts.prefix(6)), id: \.id) { product in
                            AdamsProductCard(product: product, badge: "DOORBUSTER") {
                                addProductToGarage(product)
                            }
                            .frame(width: 200)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    // MARK: - New Products Section
    
    private var newProductsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "New Products", filterType: .tag("new"))
            
            if shopifyService.isLoading {
                loadingView
            } else if shopifyService.newArrivalProducts.isEmpty {
                emptyTagSection(message: "No new arrivals available")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(shopifyService.newArrivalProducts.prefix(6)), id: \.id) { product in
                            AdamsProductCard(product: product, badge: "NEW") {
                                addProductToGarage(product)
                            }
                            .frame(width: 200)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    // MARK: - Best Sellers Section
    
    private var bestSellersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Best Sellers", filterType: .tag("best seller"))
            
            if shopifyService.isLoading {
                loadingView
            } else if shopifyService.bestSellerProducts.isEmpty {
                emptyTagSection(message: "No best sellers available")
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Array(shopifyService.bestSellerProducts.prefix(6)), id: \.id) { product in
                        AdamsProductCard(product: product, badge: "BEST SELLER") {
                            addProductToGarage(product)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Trust Badges Section (Like website footer)
    
    private var trustBadgesSection: some View {
        VStack(spacing: 24) {
            // Divider line
            Rectangle()
                .fill(AppTheme.darkGray)
                .frame(height: 1)
                .padding(.horizontal, 20)
            
            // Trust badges
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 32) {
                    trustBadge(icon: "checkmark.seal.fill", title: "Tested for Performance", subtitle: "Rigorous in-house verification")
                    trustBadge(icon: "star.fill", title: "Quality Materials", subtitle: "Premium raw materials from around the world")
                    trustBadge(icon: "sparkles", title: "New Standards", subtitle: "Pushing the limits of car care")
                    trustBadge(icon: "arrow.counterclockwise", title: "Satisfaction Guaranteed", subtitle: "Refund plus 10% if not satisfied")
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 16)
    }
    
    private func trustBadge(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppTheme.adamsRed)
            
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(AppTheme.mediumGray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 120)
        }
        .frame(width: 140)
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(title: String, filterType: ProductListView.FilterType) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            NavigationLink(destination: ProductListView(title: title, filterType: filterType)) {
                Text("View All")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.mediumGray)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
                .tint(AppTheme.adamsRed)
                .scaleEffect(1.2)
            Spacer()
        }
        .padding(.vertical, 40)
    }
    
    private func emptyTagSection(message: String) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "tag.slash")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.darkGray)
                Text(message)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.mediumGray)
            }
            Spacer()
        }
        .padding(.vertical, 30)
    }
}

// MARK: - Adam's Style Product Card (Matching website)

struct AdamsProductCard: View {
    let product: Product
    var badge: String? = nil
    var onAddToGarage: (() -> Void)? = nil
    
    var body: some View {
        NavigationLink(destination: ProductDetailView(product: product)) {
            productCardContent
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var productCardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Product Image
            ZStack(alignment: .topLeading) {
                GeometryReader { geo in
                    AsyncImage(url: URL(string: product.featuredImage ?? "")) { phase in
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
                                .frame(width: geo.size.width, height: geo.size.height)
                        case .failure:
                            Rectangle()
                                .fill(AppTheme.charcoal)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo")
                                            .font(.system(size: 30))
                                            .foregroundColor(AppTheme.mediumGray)
                                        Text("No Image")
                                            .font(.system(size: 10))
                                            .foregroundColor(AppTheme.mediumGray)
                                    }
                                )
                        @unknown default:
                            Rectangle()
                                .fill(AppTheme.charcoal)
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                .frame(height: 180)
                .clipped()
                
                // Badges
                VStack(alignment: .leading, spacing: 4) {
                    if product.isOnSale {
                        Text("Save $\(String(format: "%.0f", (Double(product.compareAtPrice ?? "0") ?? 0) - (Double(product.price) ?? 0)))")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(AppTheme.adamsRed)
                            .lineLimit(1)
                    }
                    
                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(AppTheme.adamsRed)
                            .lineLimit(1)
                    }
                }
                .padding(8)
            }
            
            // Product Info
            VStack(alignment: .leading, spacing: 8) {
                // Variant info
                Text("One Size")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.mediumGray)
                    .lineLimit(1)
                
                // Title
                Text(product.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                
                // Pricing
                HStack(spacing: 6) {
                    Text("$\(product.price)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(product.isOnSale ? AppTheme.adamsRed : .white)
                        .lineLimit(1)
                    
                    if let comparePrice = product.compareAtPrice {
                        Text("$\(comparePrice)")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.mediumGray)
                            .strikethrough()
                            .lineLimit(1)
                    }
                }
                
                // Reviews placeholder
                HStack(spacing: 3) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundColor(AppTheme.gold)
                    }
                    Text("23 reviews")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.mediumGray)
                        .lineLimit(1)
                }
                
                // Add to Cart Button
                if let onAddToGarage = onAddToGarage {
                    Button(action: onAddToGarage) {
                        HStack(spacing: 4) {
                            Text("+")
                                .font(.system(size: 14, weight: .bold))
                            Text("Add to cart")
                                .font(.system(size: 12, weight: .semibold))
                        }
                    }
                    .buttonStyle(AddToCartButtonStyle())
                    .padding(.top, 4)
                }
            }
            .padding(12)
        }
        .background(AppTheme.richBlack)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.darkGray, lineWidth: 1)
        )
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.08),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: -geo.size.width + (geo.size.width * 2 * phase))
                }
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Add to Garage Helper

extension ShopView {
    private func addProductToGarage(_ product: Product) {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        cartManager.addToCart(product)
        
        withAnimation {
            addedToCartProduct = product.id
        }
        
        // Success haptic
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                if addedToCartProduct == product.id {
                    addedToCartProduct = nil
                }
            }
        }
    }
}

// MARK: - Added to Garage Toast Animation

struct AddedToGarageToast: View {
    @State private var isAnimating = false
    @State private var checkmarkScale: CGFloat = 0
    @State private var showConfetti = false
    
    var body: some View {
        HStack(spacing: 14) {
            // Animated checkmark
            ZStack {
                Circle()
                    .fill(AppTheme.successGreen.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                
                Circle()
                    .stroke(AppTheme.successGreen, lineWidth: 2)
                    .frame(width: 44, height: 44)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.successGreen)
                    .scaleEffect(checkmarkScale)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Added to My Garage!")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text("View cart to checkout")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.mediumGray)
            }
            
            Spacer()
            
            // Garage icon with bounce
            Image(systemName: "car.fill")
                .font(.system(size: 22))
                .foregroundColor(AppTheme.adamsRed)
                .rotationEffect(.degrees(isAnimating ? 0 : -10))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.charcoal)
                .shadow(color: AppTheme.adamsRed.opacity(0.3), radius: 20, x: 0, y: 10)
                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [AppTheme.adamsRed.opacity(0.5), AppTheme.darkGray],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .padding(.horizontal, 20)
        .onAppear {
            // Animate in sequence
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                isAnimating = true
            }
            
            // Delayed checkmark pop
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.15)) {
                checkmarkScale = 1.0
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ShopView()
}
