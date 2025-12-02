//
//  ProductDetailView.swift
//  AdamsPolishes
//
//  Product detail page with image, description, and add to cart
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product
    
    @StateObject private var cartManager = CartManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImageIndex = 0
    @State private var quantity = 1
    @State private var addedToCart = false
    
    var body: some View {
        ZStack {
            AppTheme.primaryBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Product Images
                    productImageSection
                    
                    // Product Info
                    VStack(alignment: .leading, spacing: 20) {
                        // Title & Price
                        titleAndPriceSection
                        
                        // Variant selector (if multiple variants)
                        if product.variants.count > 1 {
                            variantSelector
                        }
                        
                        // Quantity selector
                        quantitySelector
                        
                        // Add to Garage Button
                        addToGarageButton
                        
                        // Description
                        descriptionSection
                    }
                    .padding(20)
                }
                .padding(.bottom, 100)
            }
            
            // Added to cart confirmation
            if addedToCart {
                addedToCartOverlay
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.primaryBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Product Details")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - Product Images
    
    private var productImageSection: some View {
        ZStack(alignment: .bottom) {
            // Main Image
            TabView(selection: $selectedImageIndex) {
                if product.images.isEmpty {
                    // Placeholder if no images
                    placeholderImage
                        .tag(0)
                } else {
                    ForEach(Array(product.images.enumerated()), id: \.element.id) { index, image in
                        AsyncImage(url: URL(string: image.url)) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(AppTheme.charcoal)
                                    .overlay(
                                        ProgressView()
                                            .tint(AppTheme.adamsRed)
                                    )
                            case .success(let loadedImage):
                                loadedImage
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            case .failure:
                                placeholderImage
                            @unknown default:
                                placeholderImage
                            }
                        }
                        .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 350)
            .background(AppTheme.charcoal)
            
            // Image indicators
            if product.images.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<product.images.count, id: \.self) { index in
                        Circle()
                            .fill(selectedImageIndex == index ? AppTheme.adamsRed : AppTheme.mediumGray)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 16)
            }
            
            // Sale Badge
            if product.isOnSale {
                VStack {
                    HStack {
                        Text("SALE")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppTheme.adamsRed)
                        
                        Spacer()
                    }
                    Spacer()
                }
                .padding(16)
            }
        }
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .fill(AppTheme.charcoal)
            .overlay(
                VStack(spacing: 12) {
                    Image(systemName: "photo")
                        .font(.system(size: 50))
                        .foregroundColor(AppTheme.mediumGray)
                    Text("No image available")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.mediumGray)
                }
            )
    }
    
    // MARK: - Title & Price
    
    private var titleAndPriceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Product Type
            if !product.productType.isEmpty {
                Text(product.productType.uppercased())
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.adamsRed)
            }
            
            // Title
            Text(product.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            // Price
            HStack(alignment: .bottom, spacing: 12) {
                Text("$\(product.price)")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(product.isOnSale ? AppTheme.adamsRed : .white)
                
                if let comparePrice = product.compareAtPrice {
                    Text("$\(comparePrice)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppTheme.mediumGray)
                        .strikethrough()
                    
                    // Savings badge
                    if let savings = calculateSavings() {
                        Text("Save $\(String(format: "%.0f", savings))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.adamsRed)
                            .cornerRadius(4)
                    }
                }
            }
            
            // Reviews placeholder
            HStack(spacing: 4) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.gold)
                }
                Text("(23 reviews)")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.mediumGray)
            }
        }
    }
    
    // MARK: - Variant Selector
    
    private var variantSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Options")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(product.variants) { variant in
                        Button(action: {}) {
                            Text(variant.title)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(AppTheme.charcoal)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppTheme.darkGray, lineWidth: 1)
                                )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Quantity Selector
    
    private var quantitySelector: some View {
        HStack(spacing: 16) {
            Text("Quantity")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 0) {
                Button(action: {
                    if quantity > 1 { quantity -= 1 }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(quantity > 1 ? .white : AppTheme.mediumGray)
                        .frame(width: 40, height: 40)
                        .background(AppTheme.charcoal)
                }
                
                Text("\(quantity)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 40)
                    .background(AppTheme.richBlack)
                
                Button(action: {
                    quantity += 1
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(AppTheme.charcoal)
                }
            }
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.darkGray, lineWidth: 1)
            )
        }
        .padding(16)
        .background(AppTheme.charcoal.opacity(0.5))
        .cornerRadius(12)
    }
    
    // MARK: - Add to Garage Button
    
    private var addToGarageButton: some View {
        Button(action: addToGarage) {
            HStack(spacing: 12) {
                Image(systemName: "car.fill")
                    .font(.system(size: 18))
                
                Text("Add to My Garage")
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                Text("$\(String(format: "%.2f", (Double(product.price) ?? 0) * Double(quantity)))")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.vertical, 18)
            .padding(.horizontal, 24)
            .background(AppTheme.adamsRed)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Description
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            if product.descriptionHtml.isEmpty && product.description.isEmpty {
                Text("No description available.")
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.lightGray)
            } else {
                HTMLTextView(html: product.descriptionHtml.isEmpty ? product.description : product.descriptionHtml)
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Added to Cart Overlay
    
    private var addedToCartOverlay: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                
                Text("Added to My Garage!")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(AppTheme.charcoal)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.bottom, 120)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(), value: addedToCart)
    }
    
    // MARK: - Actions
    
    private func addToGarage() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        for _ in 0..<quantity {
            cartManager.addToCart(product)
        }
        
        // Success haptic
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        withAnimation {
            addedToCart = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                addedToCart = false
            }
        }
    }
    
    private func calculateSavings() -> Double? {
        guard let comparePrice = product.compareAtPrice,
              let compare = Double(comparePrice),
              let price = Double(product.price) else {
            return nil
        }
        return compare - price
    }
}

// MARK: - HTML Text View

struct HTMLTextView: View {
    let html: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(parseHTMLContent().enumerated()), id: \.offset) { _, element in
                switch element {
                case .paragraph(let text):
                    Text(text)
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.lightGray)
                        .lineSpacing(4)
                    
                case .bulletList(let items):
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                            HStack(alignment: .top, spacing: 10) {
                                Text("•")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppTheme.adamsRed)
                                
                                Text(item)
                                    .font(.system(size: 15))
                                    .foregroundColor(AppTheme.lightGray)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.leading, 4)
                    
                case .numberedList(let items):
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(index + 1).")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(AppTheme.adamsRed)
                                    .frame(width: 20, alignment: .trailing)
                                
                                Text(item)
                                    .font(.system(size: 15))
                                    .foregroundColor(AppTheme.lightGray)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.leading, 4)
                    
                case .heading(let text):
                    Text(text)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top, 4)
                }
            }
        }
    }
    
    // MARK: - HTML Parsing
    
    private enum HTMLElement {
        case paragraph(String)
        case bulletList([String])
        case numberedList([String])
        case heading(String)
    }
    
    private func parseHTMLContent() -> [HTMLElement] {
        var elements: [HTMLElement] = []
        var workingHtml = html
        
        // Normalize line breaks
        workingHtml = workingHtml.replacingOccurrences(of: "\r\n", with: "\n")
        workingHtml = workingHtml.replacingOccurrences(of: "\r", with: "\n")
        
        // Replace <br> tags with newlines
        workingHtml = workingHtml.replacingOccurrences(of: "<br\\s*/?>", with: "\n", options: .regularExpression)
        
        // Extract unordered lists
        let ulPattern = "<ul[^>]*>(.*?)</ul>"
        if let ulRegex = try? NSRegularExpression(pattern: ulPattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
            let range = NSRange(workingHtml.startIndex..., in: workingHtml)
            let matches = ulRegex.matches(in: workingHtml, options: [], range: range)
            
            var lastEnd = workingHtml.startIndex
            
            for match in matches {
                // Get text before this list
                if let beforeRange = Range(NSRange(location: workingHtml.distance(from: workingHtml.startIndex, to: lastEnd), length: match.range.location - workingHtml.distance(from: workingHtml.startIndex, to: lastEnd)), in: workingHtml) {
                    let beforeText = cleanHTMLText(String(workingHtml[beforeRange]))
                    if !beforeText.isEmpty {
                        elements.append(.paragraph(beforeText))
                    }
                }
                
                // Extract list items
                if let listRange = Range(match.range(at: 1), in: workingHtml) {
                    let listContent = String(workingHtml[listRange])
                    let items = extractListItems(from: listContent)
                    if !items.isEmpty {
                        elements.append(.bulletList(items))
                    }
                }
                
                if let matchRange = Range(match.range, in: workingHtml) {
                    lastEnd = matchRange.upperBound
                }
            }
            
            // Get remaining text after last list
            let remainingText = cleanHTMLText(String(workingHtml[lastEnd...]))
            if !remainingText.isEmpty {
                elements.append(.paragraph(remainingText))
            }
        } else {
            // No lists found, just clean the HTML
            let cleanedText = cleanHTMLText(workingHtml)
            if !cleanedText.isEmpty {
                elements.append(.paragraph(cleanedText))
            }
        }
        
        // If no elements were found, return the cleaned text as a single paragraph
        if elements.isEmpty {
            let cleanedText = cleanHTMLText(html)
            if !cleanedText.isEmpty {
                elements.append(.paragraph(cleanedText))
            }
        }
        
        return elements
    }
    
    private func extractListItems(from listContent: String) -> [String] {
        var items: [String] = []
        let liPattern = "<li[^>]*>(.*?)</li>"
        
        if let liRegex = try? NSRegularExpression(pattern: liPattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
            let range = NSRange(listContent.startIndex..., in: listContent)
            let matches = liRegex.matches(in: listContent, options: [], range: range)
            
            for match in matches {
                if let itemRange = Range(match.range(at: 1), in: listContent) {
                    let itemText = cleanHTMLText(String(listContent[itemRange]))
                    if !itemText.isEmpty {
                        items.append(itemText)
                    }
                }
            }
        }
        
        return items
    }
    
    private func cleanHTMLText(_ text: String) -> String {
        var cleaned = text
        
        // Remove all HTML tags
        cleaned = cleaned.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        // Decode HTML entities
        cleaned = cleaned.replacingOccurrences(of: "&nbsp;", with: " ")
        cleaned = cleaned.replacingOccurrences(of: "&amp;", with: "&")
        cleaned = cleaned.replacingOccurrences(of: "&lt;", with: "<")
        cleaned = cleaned.replacingOccurrences(of: "&gt;", with: ">")
        cleaned = cleaned.replacingOccurrences(of: "&quot;", with: "\"")
        cleaned = cleaned.replacingOccurrences(of: "&#39;", with: "'")
        cleaned = cleaned.replacingOccurrences(of: "&apos;", with: "'")
        cleaned = cleaned.replacingOccurrences(of: "&#x27;", with: "'")
        cleaned = cleaned.replacingOccurrences(of: "&mdash;", with: "—")
        cleaned = cleaned.replacingOccurrences(of: "&ndash;", with: "–")
        cleaned = cleaned.replacingOccurrences(of: "&bull;", with: "•")
        cleaned = cleaned.replacingOccurrences(of: "&#8226;", with: "•")
        
        // Clean up whitespace
        cleaned = cleaned.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProductDetailView(product: Product.preview)
    }
}

