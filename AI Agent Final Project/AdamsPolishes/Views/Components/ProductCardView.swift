//
//  ProductCardView.swift
//  AdamsPolishes
//
//  Reusable product card component for displaying products
//

import SwiftUI

struct ProductCardView: View {
    let product: Product
    var onAddToGarage: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Product Image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: product.featuredImage ?? "")) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(AppTheme.charcoal)
                            .overlay(
                                ProgressView()
                                    .tint(AppTheme.accentRed)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(AppTheme.charcoal)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 30))
                                    .foregroundColor(AppTheme.mediumGray)
                            )
                    @unknown default:
                        Rectangle()
                            .fill(AppTheme.charcoal)
                    }
                }
                .frame(height: 160)
                .clipped()
                .cornerRadius(12)
                
                // Sale Badge
                if product.isOnSale {
                    Text("SALE")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.accentRed)
                        .cornerRadius(4)
                        .padding(8)
                }
            }
            
            // Product Info
            VStack(alignment: .leading, spacing: 6) {
                Text(product.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.pureWhite)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 8) {
                    Text("$\(product.price)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.accentRed)
                    
                    if let comparePrice = product.compareAtPrice {
                        Text("$\(comparePrice)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.mediumGray)
                            .strikethrough()
                    }
                }
                
                // Add to Garage Button
                if let onAddToGarage = onAddToGarage {
                    Button(action: onAddToGarage) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 12))
                            Text("Add to Garage")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppTheme.accentRed)
                        .cornerRadius(8)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(12)
        .background(AppTheme.cardGradient)
        .cornerRadius(16)
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Featured Product Card (Larger variant)

struct FeaturedProductCardView: View {
    let product: Product
    var onAddToGarage: (() -> Void)? = nil
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            AsyncImage(url: URL(string: product.featuredImage ?? "")) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(AppTheme.charcoal)
                        .overlay(
                            ProgressView()
                                .tint(AppTheme.accentRed)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(AppTheme.charcoal)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.mediumGray)
                        )
                @unknown default:
                    Rectangle()
                        .fill(AppTheme.charcoal)
                }
            }
            .frame(height: 220)
            .clipped()
            
            // Gradient Overlay
            LinearGradient(
                colors: [.clear, AppTheme.primaryBlack.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                if product.isOnSale {
                    Text("SALE")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppTheme.accentRed)
                        .cornerRadius(4)
                }
                
                Text(product.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text("$\(product.price)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.accentRed)
                            
                            if let comparePrice = product.compareAtPrice {
                                Text("$\(comparePrice)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.mediumGray)
                                    .strikethrough()
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Add to Garage Button
                    if let onAddToGarage = onAddToGarage {
                        Button(action: onAddToGarage) {
                            HStack(spacing: 6) {
                                Image(systemName: "car.fill")
                                    .font(.system(size: 12))
                                Text("Add to Garage")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(AppTheme.accentRed)
                            .cornerRadius(8)
                        }
                    }
                }
            }
            .padding(20)
        }
        .cornerRadius(20)
        .shadow(color: AppTheme.cardShadow, radius: 12, x: 0, y: 6)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            FeaturedProductCardView(product: Product.preview) {
                print("Added to garage")
            }
            
            HStack(spacing: 16) {
                ProductCardView(product: Product.preview) {
                    print("Added to garage")
                }
                ProductCardView(product: Product.preview) {
                    print("Added to garage")
                }
            }
        }
        .padding()
    }
    .background(AppTheme.primaryBlack)
}

// MARK: - Preview Data

extension Product {
    static var preview: Product {
        Product(
            id: "preview-1",
            title: "Premium Car Wax",
            description: "Professional grade car wax for the ultimate shine",
            descriptionHtml: "<p>Professional grade car wax for the ultimate shine. Formulated with premium ingredients for maximum protection and gloss.</p><ul><li>Long-lasting protection up to 6 months</li><li>Easy spray-on, wipe-off application</li><li>Deep wet-look gloss finish</li><li>Safe for all paint types and clear coats</li><li>UV protection to prevent fading</li></ul><p>Perfect for enthusiasts who demand the best results with minimal effort.</p>",
            vendor: "Adam's Polishes",
            productType: "Wax",
            tags: ["wax", "shine", "protection"],
            variants: [
                ProductVariant(
                    id: "variant-1",
                    title: "16oz",
                    price: "24.99",
                    compareAtPrice: "29.99",
                    sku: "WAX-001",
                    availableForSale: true,
                    quantityAvailable: 100
                )
            ],
            images: []
        )
    }
}

