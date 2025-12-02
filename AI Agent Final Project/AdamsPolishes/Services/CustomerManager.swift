//
//  CustomerManager.swift
//  AdamsPolishes
//
//  Manages customer authentication state and Shopify customer API interactions
//

import Foundation
import SwiftUI

@MainActor
class CustomerManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = CustomerManager()
    
    // MARK: - Published Properties
    @Published var customer: Customer?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let shopDomain = "test-store-project-56.myshopify.com"
    private let storefrontAccessToken = "04441fa45bc4d347bd7f634c86e6d5cd"
    
    private var apiURL: URL {
        URL(string: "https://\(shopDomain)/api/2024-01/graphql.json")!
    }
    
    // UserDefaults keys
    private let accessTokenKey = "customerAccessToken"
    private let tokenExpiryKey = "customerTokenExpiry"
    
    // MARK: - Initialization
    
    private init() {
        // Check for existing session on init
        Task {
            await checkExistingSession()
        }
    }
    
    // MARK: - Public Methods
    
    /// Create a new customer account
    func createAccount(email: String, password: String, firstName: String?, lastName: String?, acceptsMarketing: Bool = false) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let firstNameParam = firstName != nil ? "firstName: \"\(firstName!)\"," : ""
        let lastNameParam = lastName != nil ? "lastName: \"\(lastName!)\"," : ""
        
        let mutation = """
        mutation {
            customerCreate(input: {
                email: "\(email)",
                password: "\(password)",
                \(firstNameParam)
                \(lastNameParam)
                acceptsMarketing: \(acceptsMarketing)
            }) {
                customer {
                    id
                    email
                    firstName
                    lastName
                    acceptsMarketing
                    createdAt
                }
                customerUserErrors {
                    field
                    message
                }
            }
        }
        """
        
        do {
            let response: CustomerCreateResponse = try await executeQuery(mutation)
            
            if let errors = response.data.customerCreate?.customerUserErrors, !errors.isEmpty {
                errorMessage = errors.map { $0.message }.joined(separator: "\n")
                isLoading = false
                return false
            }
            
            if response.data.customerCreate?.customer != nil {
                // Account created successfully, now sign in
                isLoading = false
                return await signIn(email: email, password: password)
            }
            
            errorMessage = "Failed to create account. Please try again."
            isLoading = false
            return false
            
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    /// Sign in an existing customer
    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let mutation = """
        mutation {
            customerAccessTokenCreate(input: {
                email: "\(email)",
                password: "\(password)"
            }) {
                customerAccessToken {
                    accessToken
                    expiresAt
                }
                customerUserErrors {
                    field
                    message
                }
            }
        }
        """
        
        do {
            let response: CustomerAccessTokenCreateResponse = try await executeQuery(mutation)
            
            if let errors = response.data.customerAccessTokenCreate?.customerUserErrors, !errors.isEmpty {
                errorMessage = errors.map { $0.message }.joined(separator: "\n")
                isLoading = false
                return false
            }
            
            if let token = response.data.customerAccessTokenCreate?.customerAccessToken {
                // Store the token
                saveAccessToken(token)
                
                // Fetch customer details
                let success = await fetchCustomerDetails(accessToken: token.accessToken)
                isLoading = false
                return success
            }
            
            errorMessage = "Invalid email or password."
            isLoading = false
            return false
            
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    /// Sign out the current customer
    func signOut() {
        // Clear stored token
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: tokenExpiryKey)
        
        // Clear customer data
        customer = nil
        isLoggedIn = false
        errorMessage = nil
    }
    
    /// Send password reset email
    func recoverPassword(email: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let mutation = """
        mutation {
            customerRecover(email: "\(email)") {
                customerUserErrors {
                    field
                    message
                }
            }
        }
        """
        
        do {
            let response: CustomerRecoverResponse = try await executeQuery(mutation)
            
            if let errors = response.data.customerRecover?.customerUserErrors, !errors.isEmpty {
                errorMessage = errors.map { $0.message }.joined(separator: "\n")
                isLoading = false
                return false
            }
            
            isLoading = false
            return true
            
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    /// Refresh customer data
    func refreshCustomerData() async {
        guard let token = getStoredAccessToken() else { return }
        _ = await fetchCustomerDetails(accessToken: token)
    }
    
    // MARK: - Private Methods
    
    /// Check for existing session on app launch
    private func checkExistingSession() async {
        guard let token = getStoredAccessToken(),
              let expiry = UserDefaults.standard.string(forKey: tokenExpiryKey) else {
            return
        }
        
        // Check if token is expired
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var expiryDate: Date?
        expiryDate = isoFormatter.date(from: expiry)
        
        if expiryDate == nil {
            isoFormatter.formatOptions = [.withInternetDateTime]
            expiryDate = isoFormatter.date(from: expiry)
        }
        
        if let date = expiryDate, date < Date() {
            // Token expired, clear it
            signOut()
            return
        }
        
        // Token valid, fetch customer details
        _ = await fetchCustomerDetails(accessToken: token)
    }
    
    /// Fetch customer details using access token
    private func fetchCustomerDetails(accessToken: String) async -> Bool {
        let query = """
        {
            customer(customerAccessToken: "\(accessToken)") {
                id
                email
                firstName
                lastName
                phone
                acceptsMarketing
                createdAt
                updatedAt
                defaultAddress {
                    id
                    address1
                    address2
                    city
                    province
                    country
                    zip
                    phone
                    firstName
                    lastName
                }
                addresses(first: 10) {
                    edges {
                        node {
                            id
                            address1
                            address2
                            city
                            province
                            country
                            zip
                            phone
                            firstName
                            lastName
                        }
                    }
                }
                orders(first: 10) {
                    edges {
                        node {
                            id
                            orderNumber
                            processedAt
                            financialStatus
                            fulfillmentStatus
                            totalPrice {
                                amount
                                currencyCode
                            }
                            lineItems(first: 10) {
                                edges {
                                    node {
                                        title
                                        quantity
                                    }
                                }
                            }
                        }
                    }
                    pageInfo {
                        hasNextPage
                        endCursor
                    }
                }
            }
        }
        """
        
        do {
            let response: CustomerQueryResponse = try await executeQuery(query)
            
            if let shopifyCustomer = response.data.customer {
                self.customer = shopifyCustomer.toCustomer()
                self.isLoggedIn = true
                return true
            }
            
            // Token invalid, clear it
            signOut()
            return false
            
        } catch {
            print("Error fetching customer: \(error)")
            return false
        }
    }
    
    /// Execute a GraphQL query
    private func executeQuery<T: Codable>(_ query: String) async throws -> T {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(storefrontAccessToken, forHTTPHeaderField: "X-Shopify-Storefront-Access-Token")
        
        let body = ["query": query]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw CustomerError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    /// Save access token to UserDefaults
    private func saveAccessToken(_ token: CustomerAccessToken) {
        UserDefaults.standard.set(token.accessToken, forKey: accessTokenKey)
        UserDefaults.standard.set(token.expiresAt, forKey: tokenExpiryKey)
    }
    
    /// Get stored access token
    private func getStoredAccessToken() -> String? {
        UserDefaults.standard.string(forKey: accessTokenKey)
    }
}

// MARK: - Customer Errors

enum CustomerError: Error, LocalizedError {
    case invalidResponse
    case invalidCredentials
    case accountExists
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidCredentials:
            return "Invalid email or password"
        case .accountExists:
            return "An account with this email already exists"
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}

