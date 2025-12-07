import SwiftUI

struct MyBookingsView: View {
    @EnvironmentObject var store: BookingStore
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundLight.ignoresSafeArea()
                
                if store.bookings.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No Bookings Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        Text("Book your first court or join a drop-in session!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
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
                            
                            ForEach(store.bookings) { booking in
                                BookingRow(booking: booking)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct BookingRow: View {
    let booking: Booking
    @EnvironmentObject var store: BookingStore
    
    var statusColor: Color {
        switch booking.status.lowercased() {
        case "confirmed": return .green
        case "pending": return .orange
        case "completed": return .gray
        case "cancelled": return .red
        default: return .blue
        }
    }
    
    var body: some View {
        HStack {
            // Date Box
            VStack {
                Text(dateDay(from: booking.date))
                    .font(.title2)
                    .fontWeight(.bold)
                Text(dateMonth(from: booking.date))
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .padding()
            .frame(width: 70)
            .background(Color.white.opacity(0.5))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(booking.courtName)
                    .font(.headline)
                Text(booking.slotTime)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if booking.status.lowercased() != "cancelled" && booking.status.lowercased() != "completed" {
                    Button(action: {
                        withAnimation {
                            store.cancelBooking(id: booking.id)
                        }
                    }) {
                        Text("Cancel Booking")
                            .font(.caption)
                            .foregroundColor(.red)
                            .underline()
                    }
                    .padding(.top, 4)
                }
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
    
    // Helpers to parse "yyyy-MM-dd"
    func dateDay(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "d"
            return formatter.string(from: date)
        }
        return "??"
    }
    
    func dateMonth(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM"
            return formatter.string(from: date).uppercased()
        }
        return "??"
    }
}
