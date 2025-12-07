import Foundation
import Combine

class BookingStore: ObservableObject {
    static let shared = BookingStore()
    
    @Published var bookings: [Booking] = []
    
    private let saveKey = "user_bookings"
    
    init() {
        loadBookings()
    }
    
    func addBooking(_ booking: Booking) {
        bookings.insert(booking, at: 0) // Newest first
        saveBookings()
    }
    
    func cancelBooking(id: String) {
        if let index = bookings.firstIndex(where: { $0.id == id }) {
            // In a real app, we would call an API cancellatoin endpoint here
            // For now, we simulate success by removing it or marking it cancelled
            // Let's remove it to keep the list clean, or we could add a status update
            
            // let's just remove it for this "MVP" workflow
            bookings.remove(at: index)
            saveBookings()
        }
    }
    
    private func saveBookings() {
        if let encoded = try? JSONEncoder().encode(bookings) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadBookings() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Booking].self, from: data) {
            bookings = decoded
        }
    }
}
