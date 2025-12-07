import SwiftUI

struct Event: Identifiable {
    let id = UUID()
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
    let events = [
        Event(
            title: "Royal Clash Tournament",
            date: "6 Feb 2026",
            time: "10:00 AM - 6:00 PM",
            location: "Main Court Hall",
            entryFee: "$25 / Player",
            description: "Join the ultimate showdown! Singles and Doubles categories available. Prizes worth $5000.",
            rules: ["Feather shuttles only", "Standard BWF scoring", "Non-marking shoes mandatory"],
            color: .blue,
            icon: "trophy.fill"
        ),
        Event(
            title: "Winter Camp",
            date: "starts: 25 Dec 2025",
            time: "9:00 AM - 1:00 PM (Daily)",
            location: "Training Center",
            entryFee: "$150 / Person",
            description: "Intensive 3-day training camp with pro coaches. Perfect for intermediate players looking to level up their skills.",
            rules: ["Bring your own racket", "Water and snacks provided", "Certificate on completion"],
            color: .cyan,
            icon: "snowflake"
        )
    ]
    
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
                        
                        // Events List
                        ForEach(events) { event in
                            EventCard(event: event)
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
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header with Icon
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(event.date)
                        .font(.headline)
                        .foregroundColor(event.color)
                        .padding(.top, 2)
                }
                
                Spacer()
                
                Image(systemName: event.icon)
                    .font(.system(size: 30))
                    .foregroundColor(event.color)
                    .padding()
                    .background(event.color.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Divider()
            
            Text(event.description)
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
                    .background(LinearGradient(colors: [event.color, event.color.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(12)
                    .shadow(color: event.color.opacity(0.3), radius: 5, x: 0, y: 5)
            }
        }
        .padding()
        .liquidGlass()
        .padding(.horizontal)
    }
}
