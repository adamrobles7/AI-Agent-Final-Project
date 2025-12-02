//
//  ShineAdvisorModels.swift
//  AdamsPolishes
//
//  Models for the AI Shine Advisor recommendation engine
//

import Foundation

// MARK: - Chat Message

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: MessageRole
    let content: String
    let timestamp: Date
    var productRecommendation: ProductRecommendation?
    
    enum MessageRole: String, Codable {
        case user
        case assistant
        case system
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Product Recommendation (JSON output from AI)

struct ProductRecommendation: Decodable {
    let recommendedProducts: [RecommendedProduct]
    let reasoning: String?
    let customerGoal: String?
    
    // Computed properties with defaults
    var safeReasoning: String {
        reasoning ?? ""
    }
    
    var safeCustomerGoal: String {
        customerGoal ?? ""
    }
    
    // Legacy support for searchCriteria
    var searchCriteria: [ProductSearchCriteria] {
        recommendedProducts.map { product in
            ProductSearchCriteria(
                productType: product.productTitle,
                tags: [],
                priority: product.priority ?? 1,
                reason: product.reason ?? ""
            )
        }
    }
    
    struct RecommendedProduct: Decodable, Identifiable {
        var id: String { productTitle }
        let productTitle: String  // EXACT product title from catalog
        let priority: Int?        // 1 = must have, 2 = recommended, 3 = nice to have
        let reason: String?
        
        // Computed properties with defaults
        var safePriority: Int {
            priority ?? 1
        }
        
        var safeReason: String {
            reason ?? "Recommended for your needs"
        }
        
        // Custom decoding to handle variations in JSON keys
        enum CodingKeys: String, CodingKey {
            case productTitle
            case priority
            case reason
            // Alternative keys the AI might use
            case product_title
            case title
            case name
            case productName
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Try multiple possible keys for product title
            if let title = try? container.decode(String.self, forKey: .productTitle) {
                productTitle = title
            } else if let title = try? container.decode(String.self, forKey: .product_title) {
                productTitle = title
            } else if let title = try? container.decode(String.self, forKey: .title) {
                productTitle = title
            } else if let title = try? container.decode(String.self, forKey: .name) {
                productTitle = title
            } else if let title = try? container.decode(String.self, forKey: .productName) {
                productTitle = title
            } else {
                productTitle = "Unknown Product"
            }
            
            priority = try? container.decode(Int.self, forKey: .priority)
            reason = try? container.decode(String.self, forKey: .reason)
        }
    }
    
    struct ProductSearchCriteria: Codable, Identifiable {
        var id: String { productType + (tags.first ?? "") }
        let productType: String
        let tags: [String]
        let priority: Int
        let reason: String
    }
}

// MARK: - Product Types & Tags Reference

struct ProductCatalog {
    // Product Types / Collections matching Adam's Polishes
    static let productTypes = [
        "car-shampoo",
        "wheel-cleaner",
        "tire-shine",
        "interior-cleaner",
        "leather-conditioner",
        "glass-cleaner",
        "quick-detailer",
        "spray-wax",
        "ceramic-coating",
        "graphene-coating",
        "polish",
        "compound",
        "clay-bar",
        "iron-remover",
        "tar-remover",
        "bug-remover",
        "foam-cannon",
        "pressure-washer",
        "microfiber-towel",
        "applicator-pad",
        "brush",
        "drying-towel",
        "detailing-kit",
        "air-freshener",
        "odor-eliminator"
    ]
    
    // Tags for filtering
    static let tags = [
        // Vehicle Type
        "car", "truck", "suv", "motorcycle", "rv", "boat",
        
        // Surface Type
        "paint", "wheels", "tires", "glass", "interior", "leather",
        "vinyl", "plastic", "chrome", "trim", "fabric", "carpet",
        
        // Condition/Goal
        "deep-clean", "maintenance", "protection", "restoration",
        "scratch-removal", "swirl-removal", "water-spots",
        
        // Product Features
        "ceramic-infused", "graphene", "hydrophobic", "uv-protection",
        "ph-neutral", "biodegradable", "concentrate", "ready-to-use",
        
        // Experience Level
        "beginner-friendly", "professional", "enthusiast",
        
        // Application
        "spray", "foam", "gel", "liquid", "paste",
        
        // Special
        "best-seller", "new-arrival", "bundle", "value-pack",
        "waterless", "rinseless"
    ]
}

// MARK: - OpenAI API Models

struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Double
    let max_tokens: Int
    let response_format: ResponseFormat?
    
    struct ResponseFormat: Codable {
        let type: String
    }
}

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIResponse: Codable {
    let id: String
    let choices: [Choice]
    let usage: Usage?
    
    struct Choice: Codable {
        let index: Int
        let message: OpenAIMessage
        let finish_reason: String?
    }
    
    struct Usage: Codable {
        let prompt_tokens: Int
        let completion_tokens: Int
        let total_tokens: Int
    }
}

// MARK: - Quick Question Options

struct QuickQuestion: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let prompt: String
    
    static let suggestions: [QuickQuestion] = [
        QuickQuestion(
            icon: "sparkles",
            title: "First time detailer",
            prompt: "I'm new to car detailing and want to start taking better care of my car. What products should I start with?"
        ),
        QuickQuestion(
            icon: "car.fill",
            title: "Full exterior wash",
            prompt: "I want to do a complete exterior wash and protection for my car. What do I need?"
        ),
        QuickQuestion(
            icon: "chair.lounge.fill",
            title: "Interior deep clean",
            prompt: "My car's interior is dirty and needs a deep clean. I have leather seats and plastic trim."
        ),
        QuickQuestion(
            icon: "drop.fill",
            title: "Ceramic coating",
            prompt: "I want to apply ceramic coating to my car for long-lasting protection. What products and prep do I need?"
        ),
        QuickQuestion(
            icon: "circle.circle",
            title: "Wheel & tire care",
            prompt: "I want to clean my wheels and make my tires look new. What should I use?"
        ),
        QuickQuestion(
            icon: "sun.max.fill",
            title: "Remove scratches",
            prompt: "My car has light scratches and swirl marks. How can I remove them and restore the paint?"
        )
    ]
}

