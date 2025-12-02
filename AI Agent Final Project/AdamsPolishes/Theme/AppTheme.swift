//
//  AppTheme.swift
//  AdamsPolishes
//
//  Brand colors and styling matching adamspolishes.com
//

import SwiftUI

struct AppTheme {
    // MARK: - Brand Colors (Matching adamspolishes.com)
    
    // Blacks - Clean, deep blacks like the website
    static let primaryBlack = Color(hex: "000000")
    static let richBlack = Color(hex: "0D0D0D")
    static let charcoal = Color(hex: "1A1A1A")
    static let darkGray = Color(hex: "2D2D2D")
    
    // Reds - Adam's signature red
    static let adamsRed = Color(hex: "E31837")      // Primary brand red
    static let accentRed = Color(hex: "E31837")     // Alias for consistency
    static let brightRed = Color(hex: "FF2D47")     // Hover/active state
    static let darkRed = Color(hex: "C41230")       // Pressed state
    static let saleRed = Color(hex: "E31837")       // Sale tags
    
    // Whites & Grays
    static let pureWhite = Color.white
    static let offWhite = Color(hex: "F8F8F8")
    static let lightGray = Color(hex: "E5E5E5")
    static let mediumGray = Color(hex: "999999")
    static let textGray = Color(hex: "666666")
    
    // Accent Colors
    static let successGreen = Color(hex: "28A745")
    static let gold = Color(hex: "FFD700")
    
    // MARK: - Gradients
    
    static let heroGradient = LinearGradient(
        colors: [primaryBlack, richBlack],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let redAccentGradient = LinearGradient(
        colors: [adamsRed, darkRed],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [charcoal, richBlack],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let promoGradient = LinearGradient(
        colors: [adamsRed, brightRed],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // MARK: - Shadows
    
    static let cardShadow = Color.black.opacity(0.5)
    static let redGlow = adamsRed.opacity(0.4)
    static let subtleShadow = Color.black.opacity(0.3)
    
    // MARK: - Typography
    
    // Using system fonts that match the clean, bold style of adamspolishes.com
    static func heading1() -> Font {
        .system(size: 32, weight: .black, design: .default)
    }
    
    static func heading2() -> Font {
        .system(size: 24, weight: .bold, design: .default)
    }
    
    static func heading3() -> Font {
        .system(size: 18, weight: .bold, design: .default)
    }
    
    static func bodyText() -> Font {
        .system(size: 16, weight: .regular, design: .default)
    }
    
    static func caption() -> Font {
        .system(size: 14, weight: .medium, design: .default)
    }
    
    static func priceText() -> Font {
        .system(size: 18, weight: .bold, design: .default)
    }
    
    static func saleBadge() -> Font {
        .system(size: 11, weight: .black, design: .default)
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Custom Button Styles (Adam's Style)

struct AdamsPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .background(
                configuration.isPressed ? AppTheme.darkRed : AppTheme.adamsRed
            )
            .cornerRadius(0) // Sharp corners like the website
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(AppTheme.adamsRed)
            .cornerRadius(4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(AppTheme.pureWhite)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(AppTheme.pureWhite, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AddToCartButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                configuration.isPressed ? AppTheme.darkRed : AppTheme.adamsRed
            )
            .cornerRadius(4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.charcoal)
            .cornerRadius(8)
            .shadow(color: AppTheme.subtleShadow, radius: 8, x: 0, y: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// MARK: - Sale Badge Component

struct SaleBadge: View {
    let text: String
    var isDoorbuster: Bool = false
    
    var body: some View {
        Text(text.uppercased())
            .font(AppTheme.saleBadge())
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isDoorbuster ? AppTheme.adamsRed : AppTheme.adamsRed)
            .cornerRadius(2)
    }
}

// MARK: - Savings Label

struct SavingsLabel: View {
    let amount: String
    
    var body: some View {
        Text("Save \(amount)")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(AppTheme.adamsRed)
    }
}
