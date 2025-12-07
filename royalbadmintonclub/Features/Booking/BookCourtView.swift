import SwiftUI
import Combine

struct BookCourtView: View {
    @StateObject private var network = NetworkManager.shared
    @State private var selectedDate = Date()
    @State private var showingStripe = false
    @State private var selectedSlot: Slot?
    
    // Alert State
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isChecking = false
    
    @State private var cancellables = Set<AnyCancellable>()
    
    // Dynamic slots generation based on logic
    var upcomingSlots: [Slot] {
        let calendar = Calendar.current
        let isWeekend = calendar.isDateInWeekend(selectedDate)
        
        let times = [
            "06:00", "09:00", "12:00", 
            "15:00", "16:00", "18:00", 
            "20:00", "22:00", "23:00"
        ]
        
        return times.map { time in
            let price = calculatePrice(time: time, isWeekend: isWeekend)
            return Slot(time: time, isAvailable: true, price: price)
        }
    }
    
    func calculatePrice(time: String, isWeekend: Bool) -> Double {
        // Parse hour
        let hour = Int(time.prefix(2)) ?? 0
        let hst = 1.13
        
        if isWeekend { return 28.32 * hst }
        if hour >= 6 && hour < 16 { return 18.00 * hst }
        if hour >= 16 && hour < 22 { return 28.32 * hst }
        if hour >= 22 || hour < 2 { return 26.54 * hst }
        return 28.32 * hst
    }
    
    func checkAndBook(slot: Slot) {
        isChecking = true
        selectedSlot = slot
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateKey = formatter.string(from: selectedDate)
        
        network.checkCourtAvailability(date: dateKey, slotTime: slot.time)
            .sink(receiveCompletion: { completion in
                isChecking = false
                switch completion {
                case .failure(let error):
                    alertMessage = "Error: \(error.localizedDescription)"
                    showAlert = true
                case .finished: break
                }
            }, receiveValue: { count in
                if count > 0 {
                    // Availability Confirmed
                    showingStripe = true
                } else {
                    alertMessage = "Sorry, no courts available for \(slot.time)"
                    showAlert = true
                }
            })
            .store(in: &cancellables)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundLight.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    HStack {
                        Text("Book a Court")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding()
                    
                    // Date Strip (Horizontal)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(0..<7) { day in
                                DateCard(
                                    date: Calendar.current.date(byAdding: .day, value: day, to: Date())!,
                                    isSelected: Calendar.current.isDate(selectedDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: day, to: Date())!)
                                )
                                .onTapGesture {
                                    withAnimation {
                                        selectedDate = Calendar.current.date(byAdding: .day, value: day, to: Date())!
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Slots Grid
                    ScrollView {
                        if isChecking {
                            ProgressView("Checking Availability...")
                                .padding(.top, 50)
                        } else {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                                ForEach(upcomingSlots) { slot in
                                    SlotCard(slot: slot)
                                        .onTapGesture {
                                            if slot.isAvailable {
                                                checkAndBook(slot: slot)
                                            }
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingStripe) {
                StripeCheckoutView(slot: selectedSlot)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct DateCard: View {
    let date: Date
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Text(dateToString(format: "EEE").uppercased())
                .font(.caption)
                .fontWeight(.bold)
            Text(dateToString(format: "d"))
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding()
        .frame(width: 70, height: 90)
        .background(isSelected ? LinearGradient.royalLiquid : LinearGradient.subtleGlass)
        .cornerRadius(18)
        .foregroundColor(isSelected ? .white : .primary)
        .shadow(color: isSelected ? .royalGradientStart.opacity(0.4) : .clear, radius: 10)
    }
    
    func dateToString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

struct SlotCard: View {
    let slot: Slot
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "clock")
                Text(slot.time)
                    .fontWeight(.bold)
            }
            
            HStack {
                Text(slot.isAvailable ? "Available" : "Booked")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(slot.isAvailable ? Color.liquidSuccess.opacity(0.2) : Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(slot.isAvailable ? .liquidSuccess : .gray)
                
                Spacer()
                
                if let price = slot.price {
                    Text("$\(Int(price))")
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .liquidGlass()
        .opacity(slot.isAvailable ? 1.0 : 0.6)
    }
}
