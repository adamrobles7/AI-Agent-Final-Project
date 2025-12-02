//
//  AccountOrdersView.swift
//  AdamsPolishes
//
//  Account and Orders page with Shopify customer authentication
//

import SwiftUI

struct AccountOrdersView: View {
    @StateObject private var customerManager = CustomerManager.shared
    @State private var showingSignIn = false
    @State private var showingCreateAccount = false
    @State private var showingForgotPassword = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AppTheme.primaryBlack
                    .ignoresSafeArea()
                
                if customerManager.isLoggedIn, let customer = customerManager.customer {
                    loggedInView(customer: customer)
                } else {
                    loggedOutView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Account")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .toolbarBackground(AppTheme.primaryBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .sheet(isPresented: $showingSignIn) {
            SignInView(isPresented: $showingSignIn, showForgotPassword: $showingForgotPassword)
        }
        .sheet(isPresented: $showingCreateAccount) {
            CreateAccountView(isPresented: $showingCreateAccount)
        }
        .sheet(isPresented: $showingForgotPassword) {
            ForgotPasswordView(isPresented: $showingForgotPassword)
        }
    }
    
    // MARK: - Logged Out View
    
    private var loggedOutView: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.charcoal)
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 44))
                            .foregroundColor(AppTheme.mediumGray)
                    }
                    
                    Text("Welcome to Adam's Polishes")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Sign in to track orders, save vehicles,\nand get personalized recommendations")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.mediumGray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.top, 40)
                
                // Sign In / Create Account Buttons
                VStack(spacing: 12) {
                    Button(action: { showingSignIn = true }) {
                        Text("Sign In")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.adamsRed)
                            .cornerRadius(8)
                    }
                    
                    Button(action: { showingCreateAccount = true }) {
                        Text("Create Account")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.charcoal)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppTheme.darkGray, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 20)
                
                // Benefits
                VStack(spacing: 16) {
                    Text("Member Benefits")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        benefitRow(icon: "shippingbox.fill", text: "Track your orders in real-time")
                        benefitRow(icon: "car.fill", text: "Save your vehicles to My Garage")
                        benefitRow(icon: "sparkles", text: "Get AI-powered product recommendations")
                        benefitRow(icon: "tag.fill", text: "Exclusive member discounts")
                        benefitRow(icon: "arrow.counterclockwise", text: "Easy returns and exchanges")
                    }
                }
                .padding(20)
                .background(AppTheme.charcoal)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                // Quick Links
                VStack(spacing: 0) {
                    quickLinkRow(icon: "questionmark.circle", title: "Help Center", showDivider: true)
                    quickLinkRow(icon: "envelope", title: "Contact Us", showDivider: true)
                    quickLinkRow(icon: "doc.text", title: "Shipping & Returns", showDivider: true)
                    quickLinkRow(icon: "lock.shield", title: "Privacy Policy", showDivider: false)
                }
                .background(AppTheme.charcoal)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                Spacer(minLength: 100)
            }
        }
    }
    
    // MARK: - Logged In View
    
    private func loggedInView(customer: Customer) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                profileHeader(customer: customer)
                
                // Tab Selector
                tabSelector
                
                // Content based on selected tab
                if selectedTab == 0 {
                    ordersContent(orders: customer.orders?.orders ?? [])
                } else {
                    accountSettingsContent
                }
                
                Spacer(minLength: 100)
            }
            .padding(.top, 16)
        }
    }
    
    // MARK: - Profile Header
    
    private func profileHeader(customer: Customer) -> some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(AppTheme.adamsRed.opacity(0.15))
                    .frame(width: 70, height: 70)
                
                Text(customer.initials)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.adamsRed)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(customer.displayName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(customer.email)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.mediumGray)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.gold)
                    
                    Text("Shine Club Member")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.gold)
                }
            }
            
            Spacer()
        }
        .padding(20)
        .background(AppTheme.charcoal)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            tabButton(title: "Orders", index: 0)
            tabButton(title: "Settings", index: 1)
        }
        .background(AppTheme.charcoal)
        .cornerRadius(8)
        .padding(.horizontal, 20)
    }
    
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        }) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(selectedTab == index ? .white : AppTheme.mediumGray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedTab == index ? AppTheme.adamsRed : Color.clear)
                .cornerRadius(8)
        }
    }
    
    // MARK: - Orders Content
    
    private func ordersContent(orders: [CustomerOrder]) -> some View {
        VStack(spacing: 16) {
            if orders.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "shippingbox")
                        .font(.system(size: 50))
                        .foregroundColor(AppTheme.mediumGray)
                    
                    Text("No Orders Yet")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Your order history will appear here\nonce you make a purchase.")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.mediumGray)
                        .multilineTextAlignment(.center)
                    
                    NavigationLink(destination: ShopView()) {
                        Text("Start Shopping")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(AppTheme.adamsRed)
                            .cornerRadius(8)
                    }
                }
                .padding(40)
                .frame(maxWidth: .infinity)
                .background(AppTheme.charcoal)
                .cornerRadius(12)
            } else {
                ForEach(orders) { order in
                    orderCard(order: order)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func orderCard(order: CustomerOrder) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.formattedOrderNumber)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(order.formattedDate)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.mediumGray)
                }
                
                Spacer()
                
                Text(order.statusDisplay)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(statusColor(for: order.fulfillmentStatus ?? order.financialStatus))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(statusColor(for: order.fulfillmentStatus ?? order.financialStatus).opacity(0.15))
                    .cornerRadius(4)
            }
            
            Divider()
                .background(AppTheme.darkGray)
            
            HStack {
                Text("\(order.itemCount) item\(order.itemCount == 1 ? "" : "s")")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.mediumGray)
                
                Spacer()
                
                Text(order.totalPrice?.formatted ?? "$0.00")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(16)
        .background(AppTheme.charcoal)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.darkGray, lineWidth: 1)
        )
    }
    
    private func statusColor(for status: String?) -> Color {
        guard let status = status?.lowercased() else { return AppTheme.mediumGray }
        
        switch status {
        case "fulfilled", "delivered", "paid":
            return AppTheme.successGreen
        case "unfulfilled", "pending", "partially_fulfilled":
            return Color.orange
        case "refunded", "voided", "cancelled":
            return AppTheme.adamsRed
        default:
            return AppTheme.mediumGray
        }
    }
    
    // MARK: - Account Settings Content
    
    private var accountSettingsContent: some View {
        VStack(spacing: 16) {
            // Account Settings
            VStack(spacing: 0) {
                settingsRow(icon: "person.fill", title: "Personal Information", showDivider: true)
                settingsRow(icon: "location.fill", title: "Saved Addresses", showDivider: true)
                settingsRow(icon: "creditcard.fill", title: "Payment Methods", showDivider: true)
                settingsRow(icon: "bell.fill", title: "Notifications", showDivider: false)
            }
            .background(AppTheme.charcoal)
            .cornerRadius(12)
            
            // Support
            VStack(spacing: 0) {
                settingsRow(icon: "questionmark.circle.fill", title: "Help Center", showDivider: true)
                settingsRow(icon: "envelope.fill", title: "Contact Support", showDivider: true)
                settingsRow(icon: "doc.text.fill", title: "Terms & Conditions", showDivider: false)
            }
            .background(AppTheme.charcoal)
            .cornerRadius(12)
            
            // Sign Out
            Button(action: {
                customerManager.signOut()
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18))
                    Text("Sign Out")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(AppTheme.adamsRed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.charcoal)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func settingsRow(icon: String, title: String, showDivider: Bool) -> some View {
        VStack(spacing: 0) {
            Button(action: {}) {
                HStack(spacing: 14) {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.adamsRed)
                        .frame(width: 24)
                    
                    Text(title)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.mediumGray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            
            if showDivider {
                Divider()
                    .background(AppTheme.darkGray)
                    .padding(.leading, 54)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.adamsRed)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
    
    private func quickLinkRow(icon: String, title: String, showDivider: Bool) -> some View {
        VStack(spacing: 0) {
            Button(action: {}) {
                HStack(spacing: 14) {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.mediumGray)
                        .frame(width: 24)
                    
                    Text(title)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.mediumGray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            
            if showDivider {
                Divider()
                    .background(AppTheme.darkGray)
                    .padding(.leading, 54)
            }
        }
    }
}

// MARK: - Sign In View

struct SignInView: View {
    @Binding var isPresented: Bool
    @Binding var showForgotPassword: Bool
    @StateObject private var customerManager = CustomerManager.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.primaryBlack
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "car.fill")
                                .font(.system(size: 50))
                                .foregroundColor(AppTheme.adamsRed)
                            
                            Text("Welcome Back")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Sign in to your Adam's Polishes account")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.mediumGray)
                        }
                        .padding(.top, 40)
                        
                        // Form
                        VStack(spacing: 20) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                
                                TextField("", text: $email)
                                    .textFieldStyle(AdamsTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .focused($focusedField, equals: .email)
                                    .placeholder(when: email.isEmpty) {
                                        Text("Enter your email")
                                            .foregroundColor(AppTheme.mediumGray)
                                    }
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                
                                HStack {
                                    if showPassword {
                                        TextField("", text: $password)
                                            .foregroundColor(.white)
                                            .textContentType(.password)
                                            .focused($focusedField, equals: .password)
                                    } else {
                                        SecureField("", text: $password)
                                            .foregroundColor(.white)
                                            .textContentType(.password)
                                            .focused($focusedField, equals: .password)
                                    }
                                    
                                    Button(action: { showPassword.toggle() }) {
                                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(AppTheme.mediumGray)
                                    }
                                }
                                .padding()
                                .background(AppTheme.charcoal)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(focusedField == .password ? AppTheme.adamsRed : AppTheme.darkGray, lineWidth: 1)
                                )
                            }
                            
                            // Forgot Password
                            HStack {
                                Spacer()
                                Button(action: {
                                    isPresented = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        showForgotPassword = true
                                    }
                                }) {
                                    Text("Forgot Password?")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppTheme.adamsRed)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Error Message
                        if let error = customerManager.errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.adamsRed)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        
                        // Sign In Button
                        Button(action: signIn) {
                            HStack {
                                if customerManager.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Sign In")
                                        .font(.system(size: 16, weight: .bold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isFormValid ? AppTheme.adamsRed : AppTheme.darkGray)
                            .cornerRadius(8)
                        }
                        .disabled(!isFormValid || customerManager.isLoading)
                        .padding(.horizontal, 24)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(AppTheme.primaryBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    private func signIn() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        Task {
            let success = await customerManager.signIn(email: email, password: password)
            if success {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                isPresented = false
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}

// MARK: - Create Account View

struct CreateAccountView: View {
    @Binding var isPresented: Bool
    @StateObject private var customerManager = CustomerManager.shared
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var acceptsMarketing = true
    @State private var showPassword = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case firstName, lastName, email, password, confirmPassword
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.primaryBlack
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 50))
                                .foregroundColor(AppTheme.adamsRed)
                            
                            Text("Create Account")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Join the Adam's Polishes community")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.mediumGray)
                        }
                        .padding(.top, 20)
                        
                        // Form
                        VStack(spacing: 16) {
                            // Name Row
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("First Name")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    TextField("", text: $firstName)
                                        .textFieldStyle(AdamsTextFieldStyle())
                                        .textContentType(.givenName)
                                        .focused($focusedField, equals: .firstName)
                                        .placeholder(when: firstName.isEmpty) {
                                            Text("First")
                                                .foregroundColor(AppTheme.mediumGray)
                                        }
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Last Name")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    TextField("", text: $lastName)
                                        .textFieldStyle(AdamsTextFieldStyle())
                                        .textContentType(.familyName)
                                        .focused($focusedField, equals: .lastName)
                                        .placeholder(when: lastName.isEmpty) {
                                            Text("Last")
                                                .foregroundColor(AppTheme.mediumGray)
                                        }
                                }
                            }
                            
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                
                                TextField("", text: $email)
                                    .textFieldStyle(AdamsTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .focused($focusedField, equals: .email)
                                    .placeholder(when: email.isEmpty) {
                                        Text("Enter your email")
                                            .foregroundColor(AppTheme.mediumGray)
                                    }
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                
                                HStack {
                                    if showPassword {
                                        TextField("", text: $password)
                                            .foregroundColor(.white)
                                            .textContentType(.newPassword)
                                            .focused($focusedField, equals: .password)
                                    } else {
                                        SecureField("", text: $password)
                                            .foregroundColor(.white)
                                            .textContentType(.newPassword)
                                            .focused($focusedField, equals: .password)
                                    }
                                    
                                    Button(action: { showPassword.toggle() }) {
                                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(AppTheme.mediumGray)
                                    }
                                }
                                .padding()
                                .background(AppTheme.charcoal)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(focusedField == .password ? AppTheme.adamsRed : AppTheme.darkGray, lineWidth: 1)
                                )
                                
                                Text("Minimum 8 characters")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.mediumGray)
                            }
                            
                            // Confirm Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                
                                SecureField("", text: $confirmPassword)
                                    .foregroundColor(.white)
                                    .textContentType(.newPassword)
                                    .padding()
                                    .background(AppTheme.charcoal)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(focusedField == .confirmPassword ? AppTheme.adamsRed : AppTheme.darkGray, lineWidth: 1)
                                    )
                                    .focused($focusedField, equals: .confirmPassword)
                                
                                if !confirmPassword.isEmpty && password != confirmPassword {
                                    Text("Passwords do not match")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.adamsRed)
                                }
                            }
                            
                            // Marketing Opt-in
                            Button(action: { acceptsMarketing.toggle() }) {
                                HStack(spacing: 12) {
                                    Image(systemName: acceptsMarketing ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 20))
                                        .foregroundColor(acceptsMarketing ? AppTheme.adamsRed : AppTheme.mediumGray)
                                    
                                    Text("Send me exclusive deals and product updates")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 24)
                        
                        // Error Message
                        if let error = customerManager.errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.adamsRed)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        
                        // Create Account Button
                        Button(action: createAccount) {
                            HStack {
                                if customerManager.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Create Account")
                                        .font(.system(size: 16, weight: .bold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isFormValid ? AppTheme.adamsRed : AppTheme.darkGray)
                            .cornerRadius(8)
                        }
                        .disabled(!isFormValid || customerManager.isLoading)
                        .padding(.horizontal, 24)
                        
                        // Terms
                        Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.mediumGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(AppTheme.primaryBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        email.contains("@") && 
        password.count >= 8 && 
        password == confirmPassword
    }
    
    private func createAccount() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        Task {
            let success = await customerManager.createAccount(
                email: email,
                password: password,
                firstName: firstName.isEmpty ? nil : firstName,
                lastName: lastName.isEmpty ? nil : lastName,
                acceptsMarketing: acceptsMarketing
            )
            if success {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                isPresented = false
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}

// MARK: - Forgot Password View

struct ForgotPasswordView: View {
    @Binding var isPresented: Bool
    @StateObject private var customerManager = CustomerManager.shared
    
    @State private var email = ""
    @State private var emailSent = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.primaryBlack
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: emailSent ? "envelope.badge.fill" : "lock.rotation")
                                .font(.system(size: 50))
                                .foregroundColor(AppTheme.adamsRed)
                            
                            Text(emailSent ? "Check Your Email" : "Reset Password")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(emailSent ? 
                                 "We've sent password reset instructions to \(email)" : 
                                 "Enter your email to receive reset instructions")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.mediumGray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 40)
                        
                        if !emailSent {
                            // Form
                            VStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Email")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    TextField("", text: $email)
                                        .textFieldStyle(AdamsTextFieldStyle())
                                        .keyboardType(.emailAddress)
                                        .textContentType(.emailAddress)
                                        .autocapitalization(.none)
                                        .autocorrectionDisabled()
                                        .placeholder(when: email.isEmpty) {
                                            Text("Enter your email")
                                                .foregroundColor(AppTheme.mediumGray)
                                        }
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // Error Message
                            if let error = customerManager.errorMessage {
                                Text(error)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.adamsRed)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                            
                            // Send Reset Email Button
                            Button(action: sendResetEmail) {
                                HStack {
                                    if customerManager.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Send Reset Email")
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(isFormValid ? AppTheme.adamsRed : AppTheme.darkGray)
                                .cornerRadius(8)
                            }
                            .disabled(!isFormValid || customerManager.isLoading)
                            .padding(.horizontal, 24)
                        } else {
                            // Success State
                            Button(action: { isPresented = false }) {
                                Text("Done")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(AppTheme.adamsRed)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(AppTheme.primaryBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && email.contains("@")
    }
    
    private func sendResetEmail() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        Task {
            let success = await customerManager.recoverPassword(email: email)
            if success {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                withAnimation {
                    emailSent = true
                }
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}

// MARK: - Custom Text Field Style

struct AdamsTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundColor(.white)
            .padding()
            .background(AppTheme.charcoal)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.darkGray, lineWidth: 1)
            )
    }
}

// MARK: - Placeholder Extension

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    AccountOrdersView()
}
