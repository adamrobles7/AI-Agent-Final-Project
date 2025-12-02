//
//  CategoryCardView.swift
//  AdamsPolishes
//
//  Category navigation matching adamspolishes.com style
//

import SwiftUI

struct CategoryCardView: View {
    let title: String
    let iconName: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(AppTheme.charcoal)
                    .frame(width: 56, height: 56)
                
                Image(systemName: iconName)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 70)
        }
    }
}

// MARK: - Shop Category Model (Matching adamspolishes.com)

struct ShopCategory: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    let handle: String // Main category tag
    let subCategories: [SubCategory]
    
    // Categories matching the actual Adam's Polishes website with sub-categories
    // IMPORTANT: Tags must EXACTLY match the tags used in Shopify
    static let categories: [ShopCategory] = [
        ShopCategory(
            title: "New",
            iconName: "sparkle",
            handle: "new",
            subCategories: [
                SubCategory(title: "Just In", tag: "just in"),
                SubCategory(title: "Limited Edition", tag: "limited edition"),
                SubCategory(title: "Seasonal", tag: "seasonal")
            ]
        ),
        ShopCategory(
            title: "Exterior",
            iconName: "car.side",
            handle: "exterior",
            subCategories: [
                SubCategory(title: "Car Shampoo", tag: "car shampoo"),
                SubCategory(title: "Wheel Cleaner", tag: "wheel cleaner"),
                SubCategory(title: "Tire Shine", tag: "tire shine"),
                SubCategory(title: "Quick Detailer", tag: "quick detailer"),
                SubCategory(title: "Wax & Sealant", tag: "wax"),
                SubCategory(title: "Ceramic", tag: "ceramic"),
                SubCategory(title: "Polish", tag: "polish"),
                SubCategory(title: "Clay Bar", tag: "clay bar")
            ]
        ),
        ShopCategory(
            title: "Interior",
            iconName: "carseat.right",
            handle: "interior",
            subCategories: [
                SubCategory(title: "All Purpose Cleaner", tag: "all purpose cleaner"),
                SubCategory(title: "Leather Care", tag: "leather"),
                SubCategory(title: "Fabric & Carpet", tag: "fabric"),
                SubCategory(title: "Glass Cleaner", tag: "glass cleaner"),
                SubCategory(title: "Plastic & Vinyl", tag: "vinyl"),
                SubCategory(title: "Odor Eliminator", tag: "odor eliminator"),
                SubCategory(title: "Air Freshener", tag: "air freshener")
            ]
        ),
        ShopCategory(
            title: "Ceramics",
            iconName: "drop.fill",
            handle: "ceramic",
            subCategories: [
                SubCategory(title: "Ceramic Coating", tag: "ceramic coating"),
                SubCategory(title: "Graphene", tag: "graphene"),
                SubCategory(title: "Spray Coating", tag: "spray coating"),
                SubCategory(title: "Prep Products", tag: "prep"),
                SubCategory(title: "Maintenance", tag: "maintenance")
            ]
        ),
        ShopCategory(
            title: "Garage",
            iconName: "house.fill",
            handle: "garage",
            subCategories: [
                SubCategory(title: "Pressure Washer", tag: "pressure washer"),
                SubCategory(title: "Foam Cannon", tag: "foam cannon"),
                SubCategory(title: "Vacuum", tag: "vacuum"),
                SubCategory(title: "Lighting", tag: "lighting"),
                SubCategory(title: "Storage", tag: "storage"),
                SubCategory(title: "Buckets", tag: "bucket")
            ]
        ),
        ShopCategory(
            title: "Towels",
            iconName: "square.stack.fill",
            handle: "towel",
            subCategories: [
                SubCategory(title: "Drying Towel", tag: "drying towel"),
                SubCategory(title: "Microfiber", tag: "microfiber"),
                SubCategory(title: "Applicator Pad", tag: "applicator pad"),
                SubCategory(title: "Wash Mitt", tag: "wash mitt"),
                SubCategory(title: "Glass Towel", tag: "glass towel")
            ]
        ),
        ShopCategory(
            title: "Apparel",
            iconName: "tshirt.fill",
            handle: "apparel",
            subCategories: [
                SubCategory(title: "T-Shirts", tag: "t-shirt"),
                SubCategory(title: "Hoodies", tag: "hoodie"),
                SubCategory(title: "Hats", tag: "hat"),
                SubCategory(title: "Accessories", tag: "accessories")
            ]
        ),
        ShopCategory(
            title: "Kits",
            iconName: "shippingbox.fill",
            handle: "kit",
            subCategories: [
                SubCategory(title: "Starter Kit", tag: "starter kit"),
                SubCategory(title: "Complete Kit", tag: "complete kit"),
                SubCategory(title: "Gift Set", tag: "gift set"),
                SubCategory(title: "Bundle", tag: "bundle")
            ]
        )
    ]
}

// MARK: - Preview

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: 12) {
            ForEach(ShopCategory.categories) { category in
                CategoryCardView(
                    title: category.title,
                    iconName: category.iconName,
                    color: AppTheme.adamsRed
                )
            }
        }
        .padding()
    }
    .background(AppTheme.primaryBlack)
}
