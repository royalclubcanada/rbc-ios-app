//
//  royalbadmintonclubApp.swift
//  royalbadmintonclub
//

import SwiftUI

@main
struct royalbadmintonclubApp: App {
    @StateObject var network = NetworkManager.shared
    @StateObject var realmManager = RealmManager.shared // Inject RealmManager
    @StateObject var bookingStore = BookingStore.shared
    @State private var selectedLocation: Location?
    
    var body: some Scene {
        WindowGroup {
            if realmManager.currentUser != nil {
                if selectedLocation != nil {
                    MainTabView(selectedLocation: $selectedLocation)
                        .environmentObject(network)
                        .environmentObject(realmManager)
                        .environmentObject(bookingStore)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else {
                    LocationSelectionView(selectedLocation: $selectedLocation)
                        .environmentObject(network)
                        .environmentObject(realmManager)
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
                }
            } else {
                LoginView()
                    .environmentObject(network)
                    .environmentObject(realmManager)
                    .transition(.opacity)
            }
        }
    }
}
