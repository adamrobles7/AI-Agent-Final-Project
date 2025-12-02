//
//  ContentView.swift
//  AdamsPolishes
//
//  Main navigation container for Adam's Polishes app
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cartManager = CartManager.shared
    
    var body: some View {
        TabView {
            ShopView()
                .tabItem {
                    Label("Shop", systemImage: "cart.fill")
                }
            
            MyGarageView()
                .tabItem {
                    Label("My Garage", systemImage: "car.fill")
                }
                .badge(cartManager.itemCount > 0 ? cartManager.itemCount : 0)
            
            ShineAdvisorView()
                .tabItem {
                    Label("Shine Advisor", systemImage: "sparkles")
                }
            
            AccountOrdersView()
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
        }
        .tint(AppTheme.accentRed)
    }
}

#Preview {
    ContentView()
}
