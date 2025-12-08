import SwiftUI
import RealmSwift

// Note: Event model is in Models/Realm/Event.swift but we need a DTO for EventDetails display
struct EventDTO: Identifiable {
    let id: String
    let title: String
    let date: String
    let time: String
    let location: String
    let entryFee: String
    let description: String
    let rules: [String]
    let color: Color
    let icon: String
}

struct EventsView: View {
    @ObservedResults(Event.self, sortDescriptor: SortDescriptor(keyPath: "date", ascending: true)) var events
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundLight.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Upcoming Events")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                Text("Tournaments & Camps")
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Events List (Real-time from Realm)
                        ForEach(events) { event in
                            EventCard(event: event)
                        }
                        
                        if events.isEmpty {
                            VStack(spacing: 15) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.system(size: 50))
                                    .foregroundColor(.secondary)
                                Text("No upcoming events")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 50)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct EventCard: View {
    @ObservedRealmObject var event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header with Icon
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(formattedDate)
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.top, 2)
                }
                
                Spacer()
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Divider()
            
            Text(event.details)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // Action Button
            NavigationLink(destination: EventDetailsView(event: event)) {
                Text("View Details")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(LinearGradient(colors: [.blue, Color.blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(12)
                    .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 5)
            }
        }
        .padding()
        .liquidGlass()
        .padding(.horizontal)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: event.date)
    }
}
