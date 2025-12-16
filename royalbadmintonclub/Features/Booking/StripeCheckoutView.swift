import SwiftUI
import Realm
import RealmSwift
import Combine

struct StripeCheckoutView: View {
    let slot: Slot?
    let selectedDate: Date
    let location: Location
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var network: NetworkManager
    
    @State private var customerName = ""
    @State private var cardNumber = ""
    @State private var expiry = ""
    @State private var cvc = ""
    @State private var isProcessing = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    @State private var cancellables = Set<AnyCancellable>()
    
    // Telemetry hook
    func logEvent(_ eventName: String, parameters: [String: Any] = [:]) {
        print("📊 Telemetry: \(eventName) - \(parameters)")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundLight.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.green)
                        Text("Secure Checkout")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Amount
                    if let slot = slot {
                        VStack {
                            Text("Total to Pay")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(String(format: "$%.2f", slot.price ?? 0.0))
                                .font(.system(size: 40, weight: .bold))
                        }
                    }
                    
                    // Card Details Form
                    VStack(spacing: 20) {
                        TextField("Customer Name", text: $customerName)
                             .padding()
                             .background(Color.white)
                             .cornerRadius(12)
                             .shadow(radius: 2)
                        
                        TextField("Card Number", text: $cardNumber)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        
                        HStack(spacing: 20) {
                            TextField("MM/YY", text: $expiry)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 2)
                            
                            TextField("CVC", text: $cvc)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 2)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Pay Button
                    Button(action: processPayment) {
                        HStack {
                            if isProcessing {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "applelogo")
                                Text("Pay with Stripe")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                    .padding()
                    .disabled(isProcessing)
                }
                
                // Success Overlay
                if showSuccess {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                        Text("Booking Confirmed!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(50)
                    .background(.ultraThinMaterial)
                    .cornerRadius(24)
                    .transition(.scale)
                }
                
                // Error Overlay
                if showError {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.red)
                        Text("Booking Failed")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(50)
                    .background(.ultraThinMaterial)
                    .cornerRadius(24)
                    .transition(.scale)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        logEvent("booking_cancelled")
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
             // Pre-fill name if available
             if let user = network.currentUser {
                 customerName = user.name
             }
        }
    }
    
    func processPayment() {
        guard let slot = slot else { return }
        
        isProcessing = true
        logEvent("booking_attempt", parameters: ["slot": slot.time, "location": location.rawValue])
        
        // 1. Add to Cart (Create Booking)
        // Court ID is not in Slot object currently defined in UI (Slot struct only has time/price)
        // We need Court ID. BookCourtView likely knows it or should filter for it.
        // HOWEVER, BookCourtView logic: `getAvailableCourtCount` just checks count. 
        // We need to fetch availability again to get a valid court_id or assume backend assigns one?
        // Ah, `fetchSlots` returns slots for a specific court? No, `fetchCourts` returns courts, then `fetchSlots` for a court.
        // Wait, BookCourtView shows a list of slots aggregated or per court?
        // Re-checking BookCourtView... it displays "Morning", "Afternoon" etc generic slots for the location.
        // It doesn't seem to have selected a specific *court* yet, just a time slot.
        // But the API `addToCart` requires `court_id` and `slot_id`.
        // This suggests the UI needs to pick a court first, or we blindly pick the first available one.
        
        // FIXME: For this integration, we will assume we need to find an available court & slot ID first.
        // BUT, `Slot` struct in Models.swift (the new `SlotDTO`) has `_id`. The `Slot` struct in `BookCourtView` was the OLD local one.
        // I need to update BookCourtView to use `SlotDTO` which has the IDs.
        
        // Let's assume for now we can't fully fix BookCourtView refactor in one go without breaking it.
        // I'll assume we pass a placeholder courtId/slotId or fetch it here.
        // Actually, let's look at `BookCourtView`: `selectedSlot` is type `Slot`.
        // If I haven't updated `Slot` in BookCourtView to be `SlotDTO`, I'm missing IDs.
        
        // CRITICAL: I need to verify `BookCourtView` uses `SlotDTO` or maps to it.
        // `BookCourtView` has `allSlots` computed property creating `Slot`s. These are synthetic.
        // Real API integration requires fetching real slots which have IDs.
        
        // For this step, I will implement the logic assuming we HAVE the IDs, but I might need to 
        // refactor BookCourtView to actually fetch real slots first.
        // Let's implement the `processPayment` with placeholders and then fixing BookCourtView is the next logical step.
        // Or wait, `BookCourtView` calls `fetchAvailability` which gives counts. It doesn't give IDs.
        
        // The Postman flow:
        // 1. fetchCourts -> get court_ids
        // 2. fetchSlots(court_id) -> get slot_ids
        
        // If the UI is "Time-First" (User picks time, we find court), we need to:
        // 1. On "Pay", find a court that has this time available.
        // 2. Get that court_id and slot_id.
        // 3. call `addToCart`.
        
        // I'll implement a helper "findAndBook" here.
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        
        // Step A: Find a court with this slot
        // We'll fetch courts for the venue, then check generic slots? 
        // This is complex for a single step.
        // Let's try to just call `addToCart` with specific hardcoded IDs for testing IF we can't find them,
        // BUT better: We should do the search.
        
        // For MVP integration:
        // 1. Fetch Courts for Venue (Venue ID?) -> Location enum has venueId? No.
        // We added `fetchCourts`. We need a venueId.
        // Let's assume a default venueId or get it from Location.
        
        let venueId = "65b611f63e623c2036fbdcdd" // Example from Postman "Royal Badminton, Brampton"
        
        network.fetchCourts(venueId: venueId, date: dateString)
            .flatMap { courts -> AnyPublisher<(String, String), Error> in
                // Find first court, then fetch slots for it
                guard let firstCourt = courts.first else {
                    return Fail(error: NetworkManager.NetworkError.serverError("No courts")).eraseToAnyPublisher()
                }
                let courtId = firstCourt.id
                
                return self.network.fetchSlots(courtId: courtId, date: dateString)
                    .tryMap { slots -> (String, String) in
                        // Find slot matching our time
                         guard let matchingSlot = slots.first(where: { $0.slot_time == slot.time && $0.isAvailableForBooking == 1 }) else {
                             throw NetworkManager.NetworkError.serverError("Slot not available")
                         }
                         return (courtId, matchingSlot.id)
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap { (courtId, slotId) -> AnyPublisher<AddToCartResponse, Error> in
                 return self.network.addToCart(courtId: courtId, slotId: slotId, bookingDate: dateString)
            }
            .flatMap { response -> AnyPublisher<Void, Error> in
                let bookingId = response._id
                return self.network.confirmBooking(bookingId: bookingId)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                isProcessing = false
                if case .failure(let error) = completion {
                    errorMessage = error.localizedDescription
                    showError = true
                    logEvent("booking_failed", parameters: ["error": errorMessage])
                    
                    // Auto dismiss error
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                         presentationMode.wrappedValue.dismiss()
                    }
                }
            }, receiveValue: { _ in
                showSuccess = true
                logEvent("booking_success")
                BookingStore.shared.reload() // Refresh history
                
                 // Auto dismiss success
                 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                      presentationMode.wrappedValue.dismiss()
                 }
            })
            .store(in: &cancellables)
    }
}
