import SwiftUI
import RealmSwift

struct StripeCheckoutView: View {
    let slot: Slot?
    let selectedDate: Date
    let location: Location
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var realmManager: RealmManager
    
    @State private var customerName = ""
    @State private var cardNumber = ""
    @State private var expiry = ""
    @State private var cvc = ""
    @State private var isProcessing = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Telemetry hook
    func logEvent(_ eventName: String, parameters: [String: Any] = [:]) {
        print("📊 Telemetry: \(eventName) - \(parameters)")
        // Wire to Firebase/Mixpanel here
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
    }
    
    func processPayment() {
        guard let user = realmManager.currentUser, let slot = slot else { return }
        
        isProcessing = true
        logEvent("booking_attempt", parameters: ["slot": slot.time, "location": location.rawValue])
        
        Task {
            do {
                // Calculate start and end times
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                guard let slotTime = formatter.date(from: slot.time) else {
                    throw NSError(domain: "InvalidTime", code: 1, userInfo: nil)
                }
                
                let calendar = Calendar.current
                var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
                let slotComponents = calendar.dateComponents([.hour, .minute], from: slotTime)
                components.hour = slotComponents.hour
                components.minute = slotComponents.minute
                
                guard let startTime = calendar.date(from: components) else {
                    throw NSError(domain: "InvalidTime", code: 2, userInfo: nil)
                }
                let endTime = calendar.date(byAdding: .hour, value: 1, to: startTime)!
                
                // Step 1: Create optimistic local booking (pending state)
                if let realm = realmManager.realm {
                    try realm.write {
                        let optimisticBooking = Booking(
                            courtId: nil, // Will be assigned by backend
                            userId: user.id,
                            startTime: startTime,
                            endTime: endTime,
                            status: "pending"
                        )
                        realm.add(optimisticBooking)
                    }
                }
                
                // Step 2: Call backend Realm Function
                // Function name: "bookCourt"
                // Parameters: startTime, endTime, location, userId, paymentInfo
                let result = try await user.functions.bookCourt([
                    "startTime": startTime,
                    "endTime": endTime,
                    "location": location.rawValue,
                    "userId": user.id,
                    "price": slot.price ?? 0.0
                ]) as Document
                
                // Step 3: Check result
                if let success = result["success"]?.boolValue, success {
                    await MainActor.run {
                        isProcessing = false
                        showSuccess = true
                        logEvent("booking_success", parameters: ["slot": slot.time])
                    }
                    
                    // Close after delay
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                    await MainActor.run {
                        presentationMode.wrappedValue.dismiss()
                    }
                } else {
                    throw NSError(domain: "BookingFailed", code: 3, userInfo: [
                        NSLocalizedDescriptionKey: result["message"]?.stringValue ?? "Court no longer available"
                    ])
                }
                
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = error.localizedDescription
                    showError = true
                    logEvent("booking_failed", parameters: ["error": error.localizedDescription])
                }
                
                // Close error after delay
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                await MainActor.run {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
