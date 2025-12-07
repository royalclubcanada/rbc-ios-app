import SwiftUI
import Combine

struct CheckAvailabilityView: View {
    @StateObject private var network = NetworkManager.shared
    
    @State private var selectedDate = Date()
    @State private var selectedTimeStr = "10:00"
    
    // Hardcoded slots for selection
    let availableTimeSlots = [
        "09:00", "10:00", "11:00", "12:00", 
        "13:00", "14:00", "15:00", "16:00", 
        "17:00", "18:00", "19:00", "20:00"
    ]
    
    @State private var checkResult: [Slot]?
    @State private var isChecking = false
    @State private var message: String = "Select a date and time to check"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundLight.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        
                        // Title
                        HStack {
                            Text("Check Availability")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Date Selection
                        VStack(alignment: .leading) {
                            Text("Select Date")
                                .font(.headline)
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .padding()
                                .background(Color.white.opacity(0.6))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        
                        // Time Selection
                        VStack(alignment: .leading) {
                            Text("Select Time")
                                .font(.headline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(availableTimeSlots, id: \.self) { time in
                                        Text(time)
                                            .fontWeight(.semibold)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 20)
                                            .background(
                                                selectedTimeStr == time ? 
                                                LinearGradient.royalLiquid : 
                                                LinearGradient(colors: [.white, .white], startPoint: .top, endPoint: .bottom)
                                            )
                                            .foregroundColor(selectedTimeStr == time ? .white : .primary)
                                            .cornerRadius(12)
                                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                            .onTapGesture {
                                                selectedTimeStr = time
                                                checkResult = nil // reset
                                            }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Check Button
                        Button(action: performCheck) {
                            HStack {
                                if isChecking {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Check Status")
                                        .fontWeight(.bold)
                                    Image(systemName: "magnifyingglass")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // Result Area
                        // Result Area
                        if let count = availableCount, count > 0 {
                            VStack(spacing: 15) {
                                Text("Availability Result")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                    
                                    VStack(alignment: .leading) {
                                        Text("\(count) Courts Available")
                                            .font(.headline)
                                        Text("Time: \(selectedTimeStr)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    
                                    Text("Book Now")
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .liquidGlass()
                            }
                            .padding(.horizontal)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else if !message.isEmpty && !isChecking {
                             Text(message)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    @State private var availableCount: Int? = nil
    @State private var cancellables = Set<AnyCancellable>()
    
    // Hardcoded location context (this would come from AppState in real implementation)
    // For now we assume the user selected a location and we are checking for it.
    // The API doesn't seem to take location, so we just show the count returned.
    
    func performCheck() {
        isChecking = true
        availableCount = nil
        message = ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateKey = formatter.string(from: selectedDate)
        
        // Network Call
        network.checkCourtAvailability(date: dateKey, slotTime: selectedTimeStr)
            .sink(receiveCompletion: { completion in
                isChecking = false
                switch completion {
                case .failure(let error):
                    message = "Error: \(error.localizedDescription)"
                case .finished:
                    break
                }
            }, receiveValue: { count in
                self.availableCount = count
                if count > 0 {
                    message = "\(count) Courts Available"
                } else {
                    message = "No courts available for this time."
                }
            })
            .store(in: &cancellables)
    }
}
