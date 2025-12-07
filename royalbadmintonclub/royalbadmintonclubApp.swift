//
//  royalbadmintonclubApp.swift
//  royalbadmintonclub
//

import SwiftUI

@main
struct royalbadmintonclubApp: App {
    @StateObject var network = NetworkManager.shared
    @State private var selectedLocation: Location?
    
    var body: some Scene {
        WindowGroup {
            if network.isAuthenticated {
                if selectedLocation != nil {
                    MainTabView(selectedLocation: $selectedLocation)
                        .environmentObject(network)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else {
                    LocationSelectionView(selectedLocation: $selectedLocation)
                        .environmentObject(network)
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
                }
            } else {
                LoginView()
                    .environmentObject(network)
                    .transition(.opacity)
            }
        }
    }
}
