import SwiftUI

struct StripeCheckoutView: View {
    let slot: Slot?
    @Environment(\.presentationMode) var presentationMode
    
    @State private var customerName = ""
    @State private var cardNumber = ""
    @State private var expiry = ""
    @State private var cvc = ""
    @State private var isProcessing = false
    @State private var showSuccess = false
    
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
                            Text(String(format: "$%.2f", slot.price ?? 0.0)) // Format properly with cents
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
                                Text("Pay with Stripe") // Simulating Apple Pay / Stripe
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black) // Apple Pay style
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    func processPayment() {
        isProcessing = true
        
        // Simulate Network/Stripe Delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            withAnimation {
                showSuccess = true
            }
            
            // Save booking (Simulated)
            saveBooking()
            
            // Close after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func saveBooking() {
        if let slot = slot {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: Date())
            
            let newBooking = Booking(
                id: UUID().uuidString,
                date: dateString,
                slotTime: slot.time,
                status: "confirmed",
                courtName: "Court 1" // Simulated assignment
            )
            
            DispatchQueue.main.async {
                BookingStore.shared.addBooking(newBooking)
            }
            print("Booking saved for slot: \(slot.time)")
        }
    }
}
