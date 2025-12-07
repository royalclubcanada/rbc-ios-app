import SwiftUI

struct MyBookingsView: View {
    // Mock Data
    let bookings = [
        Booking(id: "1", date: "2023-12-10", slotTime: "10:00", status: "confirmed", courtName: "Court 1"),
        Booking(id: "2", date: "2023-12-15", slotTime: "18:00", status: "pending", courtName: "Court 3"),
        Booking(id: "3", date: "2023-11-20", slotTime: "09:00", status: "completed", courtName: "Court 2")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundLight.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Text("My Bookings")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        ForEach(bookings) { booking in
                            BookingRow(booking: booking)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct BookingRow: View {
    let booking: Booking
    
    var statusColor: Color {
        switch booking.status {
        case "confirmed": return .green
        case "pending": return .orange
        case "completed": return .gray
        default: return .blue
        }
    }
    
    var body: some View {
        HStack {
            // Date Box
            VStack {
                Text(booking.date.suffix(2)) // Day mock
                    .font(.title2)
                    .fontWeight(.bold)
                Text("DEC") // Month mock
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .padding()
            .background(Color.white.opacity(0.5))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(booking.courtName)
                    .font(.headline)
                Text(booking.slotTime)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(booking.status.capitalized)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(statusColor.opacity(0.2))
                .foregroundColor(statusColor)
                .clipShape(Capsule())
        }
        .padding()
        .liquidGlass() // Our custom modifier
        .padding(.horizontal)
    }
}
