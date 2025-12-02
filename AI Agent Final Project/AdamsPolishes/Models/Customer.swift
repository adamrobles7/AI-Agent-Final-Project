//
//  Customer.swift
//  AdamsPolishes
//
//  Customer model for Shopify customer authentication
//

import Foundation

// MARK: - Customer Model

struct Customer: Codable, Identifiable {
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    let phone: String?
    let acceptsMarketing: Bool
    let createdAt: String?
    let updatedAt: String?
    let defaultAddress: CustomerAddress?
    let addresses: [CustomerAddress]?
    let orders: CustomerOrders?
    
    var displayName: String {
        if let first = firstName, let last = lastName {
            return "\(first) \(last)"
        } else if let first = firstName {
            return first
        } else if let last = lastName {
            return last
        }
        return email
    }
    
    var initials: String {
        var result = ""
        if let first = firstName?.first {
            result += String(first).uppercased()
        }
        if let last = lastName?.first {
            result += String(last).uppercased()
        }
        if result.isEmpty {
            result = String(email.prefix(2)).uppercased()
        }
        return result
    }
}

// MARK: - Customer Address

struct CustomerAddress: Codable, Identifiable {
    let id: String
    let address1: String?
    let address2: String?
    let city: String?
    let province: String?
    let country: String?
    let zip: String?
    let phone: String?
    let firstName: String?
    let lastName: String?
    
    var formatted: String {
        var parts: [String] = []
        if let addr1 = address1 { parts.append(addr1) }
        if let addr2 = address2, !addr2.isEmpty { parts.append(addr2) }
        
        var cityStateZip = ""
        if let city = city { cityStateZip += city }
        if let province = province { cityStateZip += ", \(province)" }
        if let zip = zip { cityStateZip += " \(zip)" }
        if !cityStateZip.isEmpty { parts.append(cityStateZip) }
        
        if let country = country { parts.append(country) }
        return parts.joined(separator: "\n")
    }
}

// MARK: - Customer Orders

struct CustomerOrders: Codable {
    let edges: [CustomerOrderEdge]
    let pageInfo: CustomerPageInfo?
    
    var orders: [CustomerOrder] {
        edges.map { $0.node }
    }
}

struct CustomerOrderEdge: Codable {
    let node: CustomerOrder
}

struct CustomerOrder: Codable, Identifiable {
    let id: String
    let orderNumber: Int
    let processedAt: String?
    let financialStatus: String?
    let fulfillmentStatus: String?
    let totalPrice: MoneyV2?
    let lineItems: OrderLineItems?
    
    var formattedOrderNumber: String {
        "#AP-\(orderNumber)"
    }
    
    var formattedDate: String {
        guard let dateString = processedAt else { return "" }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        
        // Try without fractional seconds
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
    
    var statusDisplay: String {
        fulfillmentStatus?.capitalized ?? financialStatus?.capitalized ?? "Processing"
    }
    
    var itemCount: Int {
        lineItems?.edges.count ?? 0
    }
}

struct OrderLineItems: Codable {
    let edges: [OrderLineItemEdge]
}

struct OrderLineItemEdge: Codable {
    let node: OrderLineItem
}

struct OrderLineItem: Codable {
    let title: String
    let quantity: Int
}

struct MoneyV2: Codable {
    let amount: String
    let currencyCode: String
    
    var formatted: String {
        guard let value = Double(amount) else { return "$\(amount)" }
        return String(format: "$%.2f", value)
    }
}

struct CustomerPageInfo: Codable {
    let hasNextPage: Bool
    let endCursor: String?
}

// MARK: - Auth Response Models

struct CustomerAccessToken: Codable {
    let accessToken: String
    let expiresAt: String
    
    var isExpired: Bool {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let expiryDate = isoFormatter.date(from: expiresAt) {
            return expiryDate < Date()
        }
        
        // Try without fractional seconds
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let expiryDate = isoFormatter.date(from: expiresAt) {
            return expiryDate < Date()
        }
        
        return false
    }
}

// MARK: - User Error

struct CustomerUserError: Codable {
    let field: [String]?
    let message: String
}

// MARK: - Shopify Response Models for Customer Auth

struct CustomerCreateResponse: Codable {
    let data: CustomerCreateData
}

struct CustomerCreateData: Codable {
    let customerCreate: CustomerCreateResult?
}

struct CustomerCreateResult: Codable {
    let customer: ShopifyCustomerNode?
    let customerUserErrors: [CustomerUserError]
}

struct CustomerAccessTokenCreateResponse: Codable {
    let data: CustomerAccessTokenCreateData
}

struct CustomerAccessTokenCreateData: Codable {
    let customerAccessTokenCreate: CustomerAccessTokenCreateResult?
}

struct CustomerAccessTokenCreateResult: Codable {
    let customerAccessToken: CustomerAccessToken?
    let customerUserErrors: [CustomerUserError]
}

struct CustomerQueryResponse: Codable {
    let data: CustomerQueryData
}

struct CustomerQueryData: Codable {
    let customer: ShopifyCustomerNode?
}

struct ShopifyCustomerNode: Codable {
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    let phone: String?
    let acceptsMarketing: Bool
    let createdAt: String?
    let updatedAt: String?
    let defaultAddress: CustomerAddress?
    let addresses: AddressConnection?
    let orders: CustomerOrders?
    
    func toCustomer() -> Customer {
        Customer(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            acceptsMarketing: acceptsMarketing,
            createdAt: createdAt,
            updatedAt: updatedAt,
            defaultAddress: defaultAddress,
            addresses: addresses?.edges.map { $0.node },
            orders: orders
        )
    }
}

struct AddressConnection: Codable {
    let edges: [AddressEdge]
}

struct AddressEdge: Codable {
    let node: CustomerAddress
}

// MARK: - Customer Recover (Password Reset)

struct CustomerRecoverResponse: Codable {
    let data: CustomerRecoverData
}

struct CustomerRecoverData: Codable {
    let customerRecover: CustomerRecoverResult?
}

struct CustomerRecoverResult: Codable {
    let customerUserErrors: [CustomerUserError]
}

// MARK: - Customer Update

struct CustomerUpdateResponse: Codable {
    let data: CustomerUpdateData
}

struct CustomerUpdateData: Codable {
    let customerUpdate: CustomerUpdateResult?
}

struct CustomerUpdateResult: Codable {
    let customer: ShopifyCustomerNode?
    let customerAccessToken: CustomerAccessToken?
    let customerUserErrors: [CustomerUserError]
}

