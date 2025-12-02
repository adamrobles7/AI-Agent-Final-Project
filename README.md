# Adam's Polishes iOS App

**Author:** Adam Robles

---

## 📱 Overview

Adam's Polishes is a native iOS shopping application built with SwiftUI that provides customers with a seamless shopping experience for automotive detailing products. The app features an AI-powered product recommendation system called **Shine Advisor** that helps customers find the perfect products for their specific needs.

---

## ✨ Features

### 🛒 Shop
- Browse products by category
- View detailed product information with images
- Sale price indicators and product tags
- Real-time product data from Shopify

### 🚗 My Garage (Cart)
- Add/remove products from cart
- View cart total and item count
- Cart badge indicator on tab bar

### 🤖 Shine Advisor (AI Assistant)
- Powered by OpenAI's GPT-4o-mini
- Conversational product recommendations
- Intelligent product matching based on customer needs
- Quick-start question suggestions
- Real-time typing indicators
- Product cards with one-tap "Add to Garage" functionality

### 👤 Account & Orders
- Customer account management
- Order history tracking

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **SwiftUI** | Modern declarative UI framework |
| **OpenAI API** | AI-powered Shine Advisor chatbot |
| **Shopify Storefront API** | Product catalog and e-commerce backend |
| **Async/Await** | Modern Swift concurrency |
| **Combine** | Reactive state management |

---

## 📁 Project Structure

```
AdamsPolishes/
├── AdamsPolishesApp.swift          # App entry point
├── ContentView.swift               # Main tab navigation
├── Info.plist                      # App configuration
│
├── Models/
│   ├── CartItem.swift              # Shopping cart item model
│   ├── Customer.swift              # Customer data model
│   ├── Product.swift               # Product data model
│   └── ShineAdvisorModels.swift    # AI chat models
│
├── Services/
│   ├── CartManager.swift           # Cart state management
│   ├── CustomerManager.swift       # Customer data handling
│   ├── OpenAIService.swift         # AI integration service
│   └── ShopifyService.swift        # Shopify API integration
│
├── Theme/
│   └── AppTheme.swift              # App-wide styling constants
│
├── Views/
│   ├── ShopView.swift              # Main shop interface
│   ├── ProductListView.swift       # Product listing
│   ├── ProductDetailView.swift     # Individual product view
│   ├── CategoryDetailView.swift    # Category browsing
│   ├── MyGarageView.swift          # Shopping cart
│   ├── ShineAdvisorView.swift      # AI chatbot interface
│   ├── AccountOrdersView.swift     # Account management
│   │
│   └── Components/
│       ├── CartItemView.swift      # Cart item component
│       ├── CategoryCardView.swift  # Category card component
│       └── ProductCardView.swift   # Product card component
│
└── Assets.xcassets/                # Images and colors
    ├── AdamsLogo.imageset/
    ├── AppIcon.appiconset/
    ├── AccentColor.colorset/
    └── LaunchBackground.colorset/
```

---

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ deployment target
- OpenAI API key (for Shine Advisor)
- Shopify Storefront API credentials

### Installation

1. Clone the repository
2. Open `AdamsPolishes.xcodeproj` in Xcode
3. Configure API keys in `OpenAIService.swift` and `ShopifyService.swift`
4. Build and run on simulator or device

---

## 🎨 Design

The app features a sleek, dark-themed interface with Adam's Polishes brand colors:
- **Primary Black** - Main background
- **Adams Red** - Accent color and CTAs
- **Charcoal & Dark Gray** - Secondary backgrounds and borders

---

## 🤖 Shine Advisor AI

The Shine Advisor uses OpenAI's GPT-4o-mini model to provide intelligent product recommendations. Key capabilities:

- **Dynamic Product Catalog**: Reads real-time product data from Shopify
- **Context-Aware Responses**: Asks clarifying questions about wheel type, tire finish preferences, interior materials, etc.
- **Smart Product Matching**: Cross-references product tags and descriptions
- **Structured Recommendations**: Returns prioritized product suggestions with reasons

---

## 📄 License

This project was created for educational purposes as part of an AI Agent Final Project.

---

## 👨‍💻 Author

**Adam Robles**

*AI Agent Final Project*
