import Foundation
import Combine

class BookingStore: ObservableObject {
    static let shared = BookingStore()
    
    @Published var bookings: [BookingDTO] = []
    
    private let saveKey = "user_bookings"
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Don't auto-load on init, allow manual refresh or view.onAppear
    }
    
    func reload() {
        // Fetch Upcoming (1) and maybe Completed (2)? for now just Upcoming
        NetworkManager.shared.fetchBookings(listingFor: 1)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching bookings: \(error)")
                }
            }, receiveValue: { [weak self] bookings in
                self?.bookings = bookings
            })
            .store(in: &cancellables)
    }
    
    func addBooking(_ booking: BookingDTO) {
        bookings.insert(booking, at: 0)
        // ideally we push to API or reload
        // Since API logic is complex (cart flow), we rely on reload() being called after successful booking flow
    }
    
    func cancelBooking(id: String) {
        // API Cancel Logic would go here
        if let index = bookings.firstIndex(where: { $0.id == id }) {
            bookings.remove(at: index)
        }
    }
    
    // Legacy support removal
    private func saveBookings() {}
    private func loadBookings() {}
}
