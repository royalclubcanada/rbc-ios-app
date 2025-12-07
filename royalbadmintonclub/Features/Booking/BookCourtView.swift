import SwiftUI
import Combine

struct BookCourtView: View {
    @StateObject private var network = NetworkManager.shared
    @State private var selectedDate = Date()
    @State private var showingStripe = false
    @State private var selectedSlot: Slot?
    
    // Alert & state
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isChecking = false
    @State private var cancellables = Set<AnyCancellable>()
    
    // Generate full day slots
    var allSlots: [Slot] {
        let times = [
            "06:00", "07:00", "08:00", "09:00", "10:00", "11:00",
            "12:00", "13:00", "14:00", "15:00", "16:00", "17:00",
            "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"
        ]
        let isWeekend = Calendar.current.isDateInWeekend(selectedDate)
        
        return times.map { time in
            let price = calculatePrice(time: time, isWeekend: isWeekend)
            return Slot(time: time, isAvailable: true, price: price)
        }
    }
    
    // Grouping
    var morningSlots: [Slot] { allSlots.filter { (Int($0.time.prefix(2)) ?? 0) < 12 } }
    var afternoonSlots: [Slot] { allSlots.filter { (Int($0.time.prefix(2)) ?? 0) >= 12 && (Int($0.time.prefix(2)) ?? 0) < 17 } }
    var eveningSlots: [Slot] { allSlots.filter { (Int($0.time.prefix(2)) ?? 0) >= 17 } }
    
    func calculatePrice(time: String, isWeekend: Bool) -> Double {
        let hour = Int(time.prefix(2)) ?? 0
        let hst = 1.13
        if isWeekend { return 28.32 * hst }
        if hour >= 6 && hour < 16 { return 18.00 * hst }
        if hour >= 16 && hour < 22 { return 28.32 * hst }
        return 26.54 * hst
    }
    
    // Haptic Feedback
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func checkAndBook(slot: Slot) {
        triggerHaptic()
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
                    showingStripe = true
                } else {
                    alertMessage = "Sorry, fully booked for \(slot.time)"
                    showAlert = true
                }
            })
            .store(in: &cancellables)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.backgroundLight.ignoresSafeArea()
                
                // Content
                ScrollView {
                    VStack(spacing: 25) {
                        // 1. Dashboard Header (Liquid Style)
                        DashboardHeaderView()
                            .padding(.horizontal)
                        
                        // 2. Date Strip (Horizontal Liquid Cards)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(0..<14) { day in
                                    let date = Calendar.current.date(byAdding: .day, value: day, to: Date())!
                                    DateCard(
                                        date: date,
                                        isSelected: Calendar.current.isDate(selectedDate, inSameDayAs: date)
                                    )
                                    .onTapGesture {
                                        triggerHaptic()
                                        withAnimation {
                                            selectedDate = date
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // 3. Sections
                        if isChecking {
                            VStack(spacing: 15) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                Text("Checking Court Availability...")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(height: 300)
                        } else {
                            LiquidSectionView(title: "Morning (6AM - 12PM)", slots: morningSlots, onSelect: checkAndBook)
                            LiquidSectionView(title: "Afternoon (12PM - 5PM)", slots: afternoonSlots, onSelect: checkAndBook)
                            LiquidSectionView(title: "Evening (5PM - 12AM)", slots: eveningSlots, onSelect: checkAndBook)
                        }
                    }
                    .padding(.top)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingStripe) {
                StripeCheckoutView(slot: selectedSlot)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

// MARK: - Components

struct DashboardHeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Good Afternoon,")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Royal Player")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 10) {
                    Label("9 Courts Active", systemImage: "sportscourt.fill")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                    
                    Label("24°C Sunny", systemImage: "sun.max.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            Spacer()
            
            // Profile / User Icon
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue.opacity(0.8))
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding()
        .liquidGlass() // Usage of Design System
    }
}

struct LiquidSectionView: View {
    let title: String
    let slots: [Slot]
    let onSelect: (Slot) -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()) // 2 Column Grid for Cards
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(slots) { slot in
                    LiquidSlotCard(slot: slot)
                        .onTapGesture {
                            onSelect(slot)
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct LiquidSlotCard: View {
    let slot: Slot
    
    var body: some View {
        VStack(spacing: 12) {
            // Time
            Text(formatTime(slot.time))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Status Indicator
            HStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("Available")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Price
            if let price = slot.price {
                Text("$\(String(format: "%.2f", price))")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .liquidGlass() // Reverting to glass
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .clear, .white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    func formatTime(_ time: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let date = formatter.date(from: time) {
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        }
        return time
    }
}

struct DateCard: View {
    let date: Date
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            Text(dateToString(format: "EEE").uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            
            Text(dateToString(format: "d"))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .frame(width: 60, height: 85)
        .background(
            ZStack {
                if isSelected {
                    LinearGradient.royalLiquid
                } else {
                    LinearGradient.subtleGlass
                }
            }
        )
        .cornerRadius(16)
        .shadow(
            color: isSelected ? Color.blue.opacity(0.4) : Color.black.opacity(0.05),
            radius: isSelected ? 10 : 5,
            x: 0,
            y: 5
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isSelected ? Color.white.opacity(0.5) : Color.white.opacity(0.2),
                    lineWidth: 1
                )
        )
    }
    
    func dateToString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}


