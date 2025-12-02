//
//  OpenAIService.swift
//  AdamsPolishes
//
//  OpenAI API integration for Shine Advisor
//

import Foundation

@MainActor
class OpenAIService: ObservableObject {
    
    // MARK: - Configuration
    private let apiKey = "YOUR_OPENAI_API_KEY"
    private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    private let model = "gpt-4o-mini" // or "gpt-4o" for better quality
    
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var error: Error?
    
    // MARK: - Singleton
    static let shared = OpenAIService()
    
    private init() {}
    
    // MARK: - Build System Prompt with Real Products
    
    private func buildSystemPrompt() -> String {
        let shopifyService = ShopifyService.shared
        let products = shopifyService.products
        
        // Build product catalog from actual Shopify data
        var productCatalog = ""
        
        if products.isEmpty {
            // Fallback if no products loaded yet
            productCatalog = "No products currently loaded. Please ask the customer to refresh the app or check back later."
        } else {
            productCatalog = "AVAILABLE PRODUCTS IN OUR CATALOG:\n\n"
            
            for product in products {
                productCatalog += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
                productCatalog += "PRODUCT: \(product.title)\n"
                productCatalog += "Price: $\(product.price)"
                if let comparePrice = product.compareAtPrice {
                    productCatalog += " (Was: $\(comparePrice) - ON SALE)"
                }
                productCatalog += "\n"
                if !product.productType.isEmpty {
                    productCatalog += "Type: \(product.productType)\n"
                }
                if !product.tags.isEmpty {
                    productCatalog += "Tags: \(product.tags.joined(separator: ", "))\n"
                }
                // Add product description for detailed product knowledge
                let cleanDescription = cleanDescriptionForPrompt(product.description)
                if !cleanDescription.isEmpty {
                    productCatalog += "Description: \(cleanDescription)\n"
                }
                productCatalog += "\n"
            }
        }
        
        return """
        You are a knowledgeable and friendly employee at Adam's Polishes, helping customers choose the best detailing products for their needs.
        
        YOUR CAPABILITIES:
        - Read and understand product titles, descriptions, tags, and types
        - Cross-reference products by their tags (e.g., wheel_cleaner, acid_free, ceramic_safe, ph_neutral, interior, exterior, etc.)
        - Match customer needs to the most appropriate products in our catalog
        
        YOUR JOB:
        1. Answer product-related questions clearly and politely
        2. Suggest products whose tags and descriptions best match the customer's needs
        3. If needed, ask ONE quick clarifying question before recommending (wheel type, paint condition, interior material, etc.)
        4. Explain WHY you're recommending each product in simple terms
        5. ONLY recommend products from the catalog below - never make up products
        6. If you don't find a perfect match, say so honestly and suggest the closest available options
        
        CONVERSATION STYLE:
        - Be helpful and conversational, like a real employee
        - Use complete sentences with proper grammar
        - Keep responses concise but informative (2-3 sentences)
        - Don't use excessive filler phrases
        
        WHEN TO ASK CLARIFYING QUESTIONS:
        
        IMPORTANT: If the customer mentions MULTIPLE things (like wheels AND tires), ask about ALL of them in ONE question.
        
        - Wheels only: "What type of wheels do you have - stock/OEM or aftermarket?"
        - Tires only: "Do you prefer a glossy wet-look or a more natural matte finish?"
        - Wheels AND Tires (MUST ask both): "What type of wheels do you have - stock/OEM or aftermarket? And for your tires, do you prefer a glossy wet-look or a more natural matte finish?"
        - Interior: "What material are we working with - leather, fabric, vinyl, or plastic?"
        - Paint correction: "What's the main issue - swirl marks, light scratches, or heavy oxidation?"
        - Protection: "Are you looking for easy maintenance or maximum durability?"
        
        EXAMPLE - Wheels and Tires:
        Customer: "I want to clean my wheels and make my tires look new"
        You MUST ask: "What type of wheels do you have - stock/OEM or aftermarket? And for your tires, do you prefer a glossy wet-look or a more natural matte finish?"
        
        HOW TO MATCH PRODUCTS:
        Look at the product TAGS and DESCRIPTIONS to find the best match:
        - Customer says "aftermarket wheels" → find products tagged "safe for all wheels", "ph neutral", "acid free"
        - Customer says "leather interior" → find products tagged "leather", "interior"
        - Customer says "matte tire finish" → find products tagged "matte", "natural", "satin"
        - Customer says "glossy tires" → find products tagged "glossy", "wet look", "shine"
        - Customer says "ceramic coated car" → find products tagged "ceramic safe", "ph neutral"
        
        \(productCatalog)
        
        WHEN RECOMMENDING PRODUCTS:
        Provide a brief explanation, then include the JSON block with your recommendations.
        
        Example response:
        "For your aftermarket wheels, I'd recommend a pH-neutral cleaner that's safe for all finishes. For the matte tire look, our natural tire dressing will give you that clean, non-greasy appearance."
        
        ```json
        {
          "recommendedProducts": [
            {
              "productTitle": "EXACT Product Title From Catalog",
              "priority": 1,
              "reason": "pH-neutral formula safe for aftermarket wheels"
            },
            {
              "productTitle": "EXACT Product Title From Catalog",
              "priority": 1,
              "reason": "Provides natural matte finish without greasy residue"
            }
          ],
          "customerGoal": "Clean aftermarket wheels and achieve matte tire finish"
        }
        ```
        
        Priority levels: 1 = must-have for their goal, 2 = recommended addition, 3 = nice-to-have optional
        
        IF NO MATCH EXISTS:
        Be honest: "I don't have an exact match for that in our current catalog, but the closest option would be [product] because [reason]."
        """
    }
    
    /// Cleans product description for use in AI prompt
    private func cleanDescriptionForPrompt(_ description: String) -> String {
        var cleaned = description
        
        // Remove HTML tags
        cleaned = cleaned.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        
        // Decode common HTML entities
        cleaned = cleaned.replacingOccurrences(of: "&nbsp;", with: " ")
        cleaned = cleaned.replacingOccurrences(of: "&amp;", with: "&")
        cleaned = cleaned.replacingOccurrences(of: "&lt;", with: "<")
        cleaned = cleaned.replacingOccurrences(of: "&gt;", with: ">")
        cleaned = cleaned.replacingOccurrences(of: "&quot;", with: "\"")
        cleaned = cleaned.replacingOccurrences(of: "&#39;", with: "'")
        cleaned = cleaned.replacingOccurrences(of: "&apos;", with: "'")
        
        // Normalize whitespace
        cleaned = cleaned.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Truncate if too long (to manage token usage)
        if cleaned.count > 500 {
            cleaned = String(cleaned.prefix(500)) + "..."
        }
        
        return cleaned
    }
    
    // MARK: - API Methods
    
    func sendMessage(
        userMessage: String,
        conversationHistory: [ChatMessage]
    ) async throws -> (String, ProductRecommendation?) {
        isLoading = true
        defer { isLoading = false }
        
        // Build messages array with dynamic system prompt
        var messages: [OpenAIMessage] = [
            OpenAIMessage(role: "system", content: buildSystemPrompt())
        ]
        
        // Add conversation history
        for message in conversationHistory {
            messages.append(OpenAIMessage(
                role: message.role.rawValue,
                content: message.content
            ))
        }
        
        // Add new user message
        messages.append(OpenAIMessage(role: "user", content: userMessage))
        
        // Create request
        let request = OpenAIRequest(
            model: model,
            messages: messages,
            temperature: 0.7,
            max_tokens: 1000,
            response_format: nil
        )
        
        // Make API call
        var urlRequest = URLRequest(url: apiURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorBody = String(data: data, encoding: .utf8) {
                print("OpenAI Error: \(errorBody)")
            }
            throw OpenAIError.apiError(statusCode: httpResponse.statusCode)
        }
        
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        guard let assistantMessage = openAIResponse.choices.first?.message.content else {
            throw OpenAIError.noResponse
        }
        
        // Parse for product recommendations
        let recommendation = extractProductRecommendation(from: assistantMessage)
        
        // Clean the message (remove JSON block for display)
        let cleanedMessage = cleanMessageForDisplay(assistantMessage)
        
        return (cleanedMessage, recommendation)
    }
    
    // MARK: - Helper Methods
    
    private func extractProductRecommendation(from message: String) -> ProductRecommendation? {
        var jsonString: String? = nil
        
        // Try multiple JSON extraction methods
        
        // Method 1: Look for ```json ... ``` format
        if let jsonStart = message.range(of: "```json"),
           let jsonEnd = message.range(of: "```", range: jsonStart.upperBound..<message.endIndex) {
            jsonString = String(message[jsonStart.upperBound..<jsonEnd.lowerBound])
        }
        
        // Method 2: Look for ``` ... ``` format (without json tag)
        if jsonString == nil,
           let jsonStart = message.range(of: "```\n"),
           let jsonEnd = message.range(of: "```", range: jsonStart.upperBound..<message.endIndex) {
            let extracted = String(message[jsonStart.upperBound..<jsonEnd.lowerBound])
            if extracted.contains("recommendedProducts") {
                jsonString = extracted
            }
        }
        
        // Method 3: Look for raw JSON with "recommendedProducts" key
        if jsonString == nil {
            if let startBrace = message.range(of: "{"),
               let _ = message.range(of: "recommendedProducts") {
                // Find the matching closing brace
                var braceCount = 0
                var endIndex = message.endIndex
                var foundStart = false
                
                for i in message.indices {
                    let char = message[i]
                    if char == "{" {
                        if !foundStart {
                            foundStart = true
                        }
                        braceCount += 1
                    } else if char == "}" {
                        braceCount -= 1
                        if braceCount == 0 && foundStart {
                            endIndex = message.index(after: i)
                            break
                        }
                    }
                }
                
                if foundStart {
                    jsonString = String(message[startBrace.lowerBound..<endIndex])
                }
            }
        }
        
        guard let json = jsonString?.trimmingCharacters(in: .whitespacesAndNewlines),
              let jsonData = json.data(using: .utf8) else {
            print("Shine Advisor: No JSON found in response")
            return nil
        }
        
        do {
            let recommendation = try JSONDecoder().decode(ProductRecommendation.self, from: jsonData)
            print("Shine Advisor: Successfully parsed \(recommendation.recommendedProducts.count) products")
            return recommendation
        } catch {
            print("Shine Advisor: Failed to parse JSON: \(error)")
            print("Shine Advisor: JSON string was: \(json)")
            return nil
        }
    }
    
    private func cleanMessageForDisplay(_ message: String) -> String {
        var cleaned = message
        
        // Remove ```json ... ``` blocks
        if let jsonStart = cleaned.range(of: "```json"),
           let jsonEnd = cleaned.range(of: "```", range: jsonStart.upperBound..<cleaned.endIndex) {
            let fullRange = jsonStart.lowerBound..<jsonEnd.upperBound
            cleaned.removeSubrange(fullRange)
        }
        
        // Remove ``` ... ``` blocks that contain JSON
        if let jsonStart = cleaned.range(of: "```\n"),
           let jsonEnd = cleaned.range(of: "```", range: jsonStart.upperBound..<cleaned.endIndex) {
            let content = String(cleaned[jsonStart.upperBound..<jsonEnd.lowerBound])
            if content.contains("recommendedProducts") || content.contains("{") {
                let fullRange = jsonStart.lowerBound..<jsonEnd.upperBound
                cleaned.removeSubrange(fullRange)
            }
        }
        
        // Remove raw JSON blocks
        if let startBrace = cleaned.range(of: "{"),
           cleaned.contains("recommendedProducts") {
            var braceCount = 0
            var endIndex = cleaned.endIndex
            var foundStart = false
            var startIndex = startBrace.lowerBound
            
            for i in cleaned.indices {
                let char = cleaned[i]
                if char == "{" {
                    if !foundStart {
                        foundStart = true
                        startIndex = i
                    }
                    braceCount += 1
                } else if char == "}" {
                    braceCount -= 1
                    if braceCount == 0 && foundStart {
                        endIndex = cleaned.index(after: i)
                        break
                    }
                }
            }
            
            if foundStart && cleaned[startIndex..<endIndex].contains("recommendedProducts") {
                cleaned.removeSubrange(startIndex..<endIndex)
            }
        }
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Initial Greeting
    
    func getInitialGreeting() -> String {
        return "Hey there! 👋 I'm here to help you find the right detailing products. What are you looking to clean or protect today?"
    }
}

// MARK: - Errors

enum OpenAIError: Error, LocalizedError {
    case invalidResponse
    case apiError(statusCode: Int)
    case noResponse
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from AI service"
        case .apiError(let statusCode):
            return "AI service error (code: \(statusCode))"
        case .noResponse:
            return "No response from AI"
        case .encodingError:
            return "Failed to encode request"
        }
    }
}
