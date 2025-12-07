import SwiftUI

struct MainTabView: View {
    @Binding var selectedLocation: Location?
    @State private var selectedTab = 0
    
    // Custom Tab Bar to get the full glass effect floating at bottom
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // Tab Content
            Group {
                switch selectedTab {
                case 0:
                    BookCourtView()
                case 1:
                    DropInView()
                case 2:
                    EventsView()
                case 3:
                    MyBookingsView()
                default:
                    Color.clear
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Push content down slightly for header
            .padding(.top, 60) 
            
            // Custom Header for Location Switch
            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            selectedLocation = nil
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                            Text(selectedLocation?.rawValue ?? "Select Location")
                                .font(.callout)
                                .fontWeight(.medium)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .shadow(radius: 4)
                        .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 50) // Safe Area
                
                Spacer()
            }
            .ignoresSafeArea()
            
            // Custom Tab Bar
            HStack {
                TabItem(icon: "sportscourt.fill", title: "Book", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                
                Spacer()
                
                TabItem(icon: "person.3.fill", title: "Drop-In", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                
                Spacer()
                
                TabItem(icon: "trophy.fill", title: "Events", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                
                Spacer()
                
                TabItem(icon: "person.crop.circle.fill", title: "My Bookings", isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .mask(Capsule())
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 10) // Lift from bottom
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct TabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: isSelected ? .bold : .regular))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(title)
                    .font(.caption2)
                    .fontWeight(isSelected ? .bold : .regular)
            }
            .foregroundColor(isSelected ? .blue : .gray)
            .animation(.spring(), value: isSelected)
        }
    }
}
