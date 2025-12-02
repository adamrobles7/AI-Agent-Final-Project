//
//  ShineAdvisorView.swift
//  AdamsPolishes
//
//  AI-powered Shine Advisor for personalized product recommendations
//

import SwiftUI

struct ShineAdvisorView: View {
    @StateObject private var openAIService = OpenAIService.shared
    @StateObject private var shopifyService = ShopifyService.shared
    @StateObject private var cartManager = CartManager.shared
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isTyping = false
    @State private var showingQuickQuestions = true
    @State private var showAddedToGarageToast = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AppTheme.primaryBlack
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Chat Messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                // Welcome Header
                                if messages.isEmpty {
                                    welcomeHeader
                                }
                                
                                // Quick Question Suggestions
                                if showingQuickQuestions && messages.count <= 1 {
                                    quickQuestionsSuggestions
                                }
                                
                                // Messages
                                ForEach(messages) { message in
                                    ChatBubbleView(message: message, onAddedToGarage: {
                                        showToast()
                                    }) { recommendation in
                                        // Handle product recommendation tap
                                    }
                                    .id(message.id)
                                }
                                
                                // Typing Indicator
                                if isTyping {
                                    TypingIndicatorView()
                                        .id("typing")
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 100)
                        }
                        .onChange(of: messages.count) { _, _ in
                            scrollToBottom(proxy: proxy)
                        }
                        .onChange(of: isTyping) { _, _ in
                            scrollToBottom(proxy: proxy)
                        }
                    }
                    
                    // Input Bar
                    inputBar
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(AppTheme.adamsRed)
                        Text("Shine Advisor")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: resetChat) {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(AppTheme.primaryBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .overlay(alignment: .bottom) {
                // Added to Garage Toast
                if showAddedToGarageToast {
                    AddedToGarageToast()
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.8)),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                        .padding(.bottom, 100)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showAddedToGarageToast)
        }
        .onAppear {
            if messages.isEmpty {
                addInitialGreeting()
            }
        }
    }
    
    // MARK: - Show Toast
    
    func showToast() {
        withAnimation {
            showAddedToGarageToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showAddedToGarageToast = false
            }
        }
    }
    
    // MARK: - Welcome Header
    
    private var welcomeHeader: some View {
        VStack(spacing: 16) {
            // AI Icon
            ZStack {
                Circle()
                    .fill(AppTheme.adamsRed.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundColor(AppTheme.adamsRed)
            }
            
            VStack(spacing: 8) {
                Text("Shine Advisor")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("AI-Powered Product Recommendations")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.mediumGray)
            }
        }
        .padding(.vertical, 24)
    }
    
    // MARK: - Quick Questions
    
    private var quickQuestionsSuggestions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Start")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.mediumGray)
                .padding(.horizontal, 4)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(QuickQuestion.suggestions) { question in
                    Button(action: {
                        sendQuickQuestion(question)
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: question.icon)
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.adamsRed)
                                .frame(width: 24)
                            
                            Text(question.title)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        .padding(14)
                        .background(AppTheme.charcoal)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.darkGray, lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Input Bar
    
    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(AppTheme.darkGray)
            
            HStack(spacing: 12) {
                // Text Field with custom placeholder
                HStack(spacing: 12) {
                    ZStack(alignment: .leading) {
                        if inputText.isEmpty {
                            Text("Ask about products...")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        TextField("", text: $inputText, axis: .vertical)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .accentColor(AppTheme.adamsRed)
                            .lineLimit(1...4)
                            .focused($isInputFocused)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(AppTheme.charcoal)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(AppTheme.darkGray, lineWidth: 1)
                )
                
                // Send Button
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(inputText.isEmpty ? AppTheme.darkGray : AppTheme.adamsRed)
                }
                .disabled(inputText.isEmpty || isTyping)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppTheme.richBlack)
        }
    }
    
    // MARK: - Actions
    
    private func addInitialGreeting() {
        let greeting = openAIService.getInitialGreeting()
        let message = ChatMessage(
            role: .assistant,
            content: greeting,
            timestamp: Date()
        )
        messages.append(message)
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        let userMessage = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        inputText = ""
        showingQuickQuestions = false
        isInputFocused = false
        
        // Add user message
        messages.append(ChatMessage(
            role: .user,
            content: userMessage,
            timestamp: Date()
        ))
        
        // Show typing indicator
        isTyping = true
        
        // Send to OpenAI
        Task {
            do {
                let (response, recommendation) = try await openAIService.sendMessage(
                    userMessage: userMessage,
                    conversationHistory: messages.dropLast() // Exclude the message we just added
                )
                
                await MainActor.run {
                    isTyping = false
                    
                    // Haptic feedback for response
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    
                    var assistantMessage = ChatMessage(
                        role: .assistant,
                        content: response,
                        timestamp: Date()
                    )
                    assistantMessage.productRecommendation = recommendation
                    
                    messages.append(assistantMessage)
                }
            } catch {
                await MainActor.run {
                    isTyping = false
                    messages.append(ChatMessage(
                        role: .assistant,
                        content: "I'm sorry, I encountered an error. Please try again or check your connection.",
                        timestamp: Date()
                    ))
                }
            }
        }
    }
    
    private func sendQuickQuestion(_ question: QuickQuestion) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        inputText = question.prompt
        sendMessage()
    }
    
    private func resetChat() {
        messages.removeAll()
        showingQuickQuestions = true
        addInitialGreeting()
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.3)) {
                if isTyping {
                    proxy.scrollTo("typing", anchor: .bottom)
                } else if let lastMessage = messages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }
}

// MARK: - Chat Bubble View

struct ChatBubbleView: View {
    let message: ChatMessage
    var onAddedToGarage: (() -> Void)? = nil
    var onRecommendationTap: ((ProductRecommendation) -> Void)?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .assistant {
                // AI Avatar
                ZStack {
                    Circle()
                        .fill(AppTheme.adamsRed.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.adamsRed)
                }
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 8) {
                // Message Bubble
                Text(message.content)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.role == .user
                            ? AppTheme.adamsRed
                            : AppTheme.charcoal
                    )
                    .cornerRadius(20)
                    .cornerRadius(message.role == .user ? 20 : 4, corners: message.role == .user ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                
                // Product Recommendations
                if let recommendation = message.productRecommendation {
                    ProductRecommendationCard(recommendation: recommendation, onAddedToGarage: onAddedToGarage)
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .user {
                // User Avatar
                ZStack {
                    Circle()
                        .fill(AppTheme.darkGray)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
    }
}

// MARK: - Product Recommendation Card

struct ProductRecommendationCard: View {
    let recommendation: ProductRecommendation
    var onAddedToGarage: (() -> Void)? = nil
    @StateObject private var shopifyService = ShopifyService.shared
    @StateObject private var cartManager = CartManager.shared
    @State private var isExpanded = true
    @State private var matchedProducts: [String: Product] = [:] // productTitle -> Product
    @State private var addedProductId: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: "bag.fill")
                        .foregroundColor(AppTheme.adamsRed)
                    
                    Text("Recommended Products")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.mediumGray)
                }
            }
            
            if isExpanded {
                // Customer Goal
                if !recommendation.safeCustomerGoal.isEmpty {
                    Text(recommendation.safeCustomerGoal)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.mediumGray)
                        .padding(.bottom, 4)
                }
                
                // ALWAYS show the AI's recommendations
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(recommendation.recommendedProducts.sorted { $0.safePriority < $1.safePriority }) { recommendedProduct in
                        if let product = matchedProducts[recommendedProduct.productTitle.lowercased()] {
                            // Found matching product in catalog - show full card
                            ProductRecommendationRowWithReason(
                                product: product,
                                reason: recommendedProduct.safeReason,
                                priority: recommendedProduct.safePriority,
                                isAdded: addedProductId == product.id
                            ) {
                                // Haptic feedback
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                
                                cartManager.addToCart(product)
                                withAnimation(.spring(response: 0.3)) {
                                    addedProductId = product.id
                                }
                                
                                // Success haptic
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                
                                // Trigger toast
                                onAddedToGarage?()
                                
                                // Reset after delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation {
                                        addedProductId = nil
                                    }
                                }
                            }
                        } else {
                            // No exact match - still show the recommendation from AI
                            AIRecommendationRow(
                                productTitle: recommendedProduct.productTitle,
                                reason: recommendedProduct.safeReason,
                                priority: recommendedProduct.safePriority
                            )
                        }
                    }
                }
                
                // Reasoning
                if !recommendation.safeReasoning.isEmpty {
                    Text(recommendation.safeReasoning)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.mediumGray)
                        .padding(.top, 8)
                }
            }
        }
        .padding(16)
        .background(AppTheme.richBlack)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.adamsRed.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            findMatchingProducts()
        }
    }
    
    private func findMatchingProducts() {
        let allProducts = shopifyService.products
        var matches: [String: Product] = [:]
        
        // Match by product title that the AI recommended
        for recommendedProduct in recommendation.recommendedProducts {
            let searchTitle = recommendedProduct.productTitle.lowercased()
            
            // Try exact match first
            if let exactMatch = allProducts.first(where: { 
                $0.title.lowercased() == searchTitle 
            }) {
                matches[searchTitle] = exactMatch
            } 
            // Try contains match if exact match fails
            else if let partialMatch = allProducts.first(where: { 
                $0.title.lowercased().contains(searchTitle) ||
                searchTitle.contains($0.title.lowercased())
            }) {
                matches[searchTitle] = partialMatch
            }
        }
        
        matchedProducts = matches
    }
}

// MARK: - AI Recommendation Row (when product not found in catalog)

struct AIRecommendationRow: View {
    let productTitle: String
    let reason: String
    let priority: Int
    
    private var priorityColor: Color {
        switch priority {
        case 1: return AppTheme.adamsRed
        case 2: return .orange
        default: return AppTheme.mediumGray
        }
    }
    
    private var priorityLabel: String {
        switch priority {
        case 1: return "Essential"
        case 2: return "Recommended"
        default: return "Optional"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Placeholder Image
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppTheme.charcoal)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.mediumGray)
                }
                
                // Product Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(productTitle)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        // Priority Badge
                        Text(priorityLabel)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(priorityColor)
                            .cornerRadius(4)
                    }
                }
            }
            
            // Reason
            Text(reason)
                .font(.system(size: 11))
                .foregroundColor(AppTheme.mediumGray)
                .lineLimit(2)
        }
        .padding(12)
        .background(AppTheme.charcoal.opacity(0.5))
        .cornerRadius(10)
    }
}

// MARK: - Product Recommendation Row with Reason

struct ProductRecommendationRowWithReason: View {
    let product: Product
    let reason: String
    let priority: Int
    var isAdded: Bool = false
    let onAddToCart: () -> Void
    
    private var priorityColor: Color {
        switch priority {
        case 1: return AppTheme.adamsRed
        case 2: return .orange
        default: return AppTheme.mediumGray
        }
    }
    
    private var priorityLabel: String {
        switch priority {
        case 1: return "Essential"
        case 2: return "Recommended"
        default: return "Optional"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Product Image
                AsyncImage(url: URL(string: product.featuredImage ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                    default:
                        Rectangle()
                            .fill(AppTheme.charcoal)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.mediumGray)
                            )
                    }
                }
                .frame(width: 60, height: 60)
                .clipped()
                .cornerRadius(8)
                
                // Product Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(product.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        // Priority Badge
                        Text(priorityLabel)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(priorityColor)
                            .cornerRadius(4)
                    }
                    
                    Text("$\(product.price)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.adamsRed)
                }
                
                // Add to Cart Button
                Button(action: onAddToCart) {
                    if isAdded {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.successGreen)
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.adamsRed)
                    }
                }
                .disabled(isAdded)
            }
            
            // Reason
            Text(reason)
                .font(.system(size: 11))
                .foregroundColor(AppTheme.mediumGray)
                .lineLimit(2)
        }
        .padding(12)
        .background(isAdded ? AppTheme.successGreen.opacity(0.1) : AppTheme.charcoal.opacity(0.5))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isAdded ? AppTheme.successGreen.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isAdded)
    }
}

// MARK: - Product Recommendation Row

struct ProductRecommendationRow: View {
    let product: Product
    let onAddToCart: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            AsyncImage(url: URL(string: product.featuredImage ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                default:
                    Rectangle()
                        .fill(AppTheme.charcoal)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.mediumGray)
                        )
                }
            }
            .frame(width: 50, height: 50)
            .clipped()
            .cornerRadius(6)
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("$\(product.price)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.adamsRed)
            }
            
            Spacer()
            
            // Add to Cart
            Button(action: onAddToCart) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.adamsRed)
            }
        }
        .padding(10)
        .background(AppTheme.charcoal.opacity(0.5))
        .cornerRadius(8)
    }
}

// MARK: - Recommendation Item View

struct RecommendationItemView: View {
    let criteria: ProductRecommendation.ProductSearchCriteria
    
    private var priorityColor: Color {
        switch criteria.priority {
        case 1: return AppTheme.adamsRed
        case 2: return .orange
        default: return AppTheme.mediumGray
        }
    }
    
    private var priorityLabel: String {
        switch criteria.priority {
        case 1: return "Essential"
        case 2: return "Recommended"
        default: return "Optional"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Product Type
                Text(formatProductType(criteria.productType))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Priority Badge
                Text(priorityLabel)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(priorityColor)
                    .cornerRadius(4)
            }
            
            // Reason
            Text(criteria.reason)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.mediumGray)
            
            // Tags
            if !criteria.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(criteria.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(AppTheme.mediumGray)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.charcoal)
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(AppTheme.charcoal.opacity(0.5))
        .cornerRadius(12)
    }
    
    private func formatProductType(_ type: String) -> String {
        type.replacingOccurrences(of: "-", with: " ").capitalized
    }
}

// MARK: - Typing Indicator

struct TypingIndicatorView: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // AI Avatar
            ZStack {
                Circle()
                    .fill(AppTheme.adamsRed.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.adamsRed)
            }
            
            // Typing Dots
            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(AppTheme.mediumGray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                        .opacity(animationPhase == index ? 1.0 : 0.5)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(AppTheme.charcoal)
            .cornerRadius(20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                animationPhase = (animationPhase + 1) % 3
            }
        }
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview

#Preview {
    ShineAdvisorView()
}
