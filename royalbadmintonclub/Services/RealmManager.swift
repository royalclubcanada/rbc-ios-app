import Foundation
import Combine
import Realm
import RealmSwift

// NOTE: Add the RealmSwift package via File -> Add Packages: https://github.com/realm/realm-swift
// MARK: - Realm Manager
class RealmManager: ObservableObject {
    static let shared = RealmManager()
    
    // Replace with your MongoDB Realm App ID
    let app = App(id: "YOUR_REALM_APP_ID")
    
    @Published var currentUser: User?
    @Published var realm: Realm?
    @Published var errorMessage: String?
    
    private init() {
        // Check if a user is already logged in
        if let user = app.currentUser {
            self.currentUser = user
            Task {
                await openRealm(user: user)
            }
        }
    }
    
    @MainActor
    func login(credentials: Credentials) async throws {
        do {
            let user = try await app.login(credentials: credentials)
            self.currentUser = user
            await openRealm(user: user)
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    @MainActor
    func logout() async {
        do {
            try await currentUser?.logOut()
            self.currentUser = nil
            self.realm = nil
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    private func openRealm(user: User) async {
        // Flexible Sync Configuration
        var config = user.flexibleSyncConfiguration(initialSubscriptions: { subs in
            // 1. Courts (All)
            if let _ = subs.first(named: "all_courts") {
                // Already subscribed
            } else {
                subs.append(QuerySubscription<Court>(name: "all_courts"))
            }
            
            // 2. Bookings (Upcoming + Recent Past)
            // We want to see availability, so we need bookings from today onwards for ALL users.
            // And maybe past bookings for THIS user?
            // For simplicity: Bookings from yesterday onwards.
            if let _ = subs.first(named: "active_bookings") {
                // update query if needed
            } else {
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                subs.append(QuerySubscription<Booking>(name: "active_bookings") {
                    $0.startTime >= yesterday
                })
            }
            
            // 3. Drop-in Sessions (Today + Upcoming)
            if let _ = subs.first(named: "active_dropins") {
            } else {
                let today = Calendar.current.startOfDay(for: Date())
                subs.append(QuerySubscription<DropInSession>(name: "active_dropins") {
                    $0.startTime >= today
                })
            }
            
            // 4. Events (Upcoming)
            if let _ = subs.first(named: "upcoming_events") {
            } else {
                let today = Calendar.current.startOfDay(for: Date())
                subs.append(QuerySubscription<Event>(name: "upcoming_events") {
                    $0.date >= today
                })
            }
        })
        
        // Handle offline opening (Open immediately if cached)
        Realm.asyncOpen(configuration: config) { result in
            switch result {
            case .success(let realm):
                DispatchQueue.main.async {
                    self.realm = realm
                    print("Realm opened successfully")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to open realm: \(error.localizedDescription)"
                }
            }
        }
    }
}
