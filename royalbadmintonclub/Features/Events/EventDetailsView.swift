import SwiftUI

struct EventDetailsView: View {
    let event: Event
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.backgroundLight.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header Image Area
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(colors: [event.color, event.color.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            .frame(height: 300) // Taller hero
                            .overlay(
                                Image(systemName: event.icon)
                                    .font(.system(size: 120))
                                    .foregroundColor(.white.opacity(0.2))
                                    .offset(x: 50, y: 50)
                            )
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(event.title)
                                .font(.system(size: 36, weight: .heavy)) // Apple style bold
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            HStack {
                                Image(systemName: "calendar")
                                Text(event.date)
                            }
                            .foregroundColor(.white.opacity(0.9))
                            .font(.headline)
                        }
                        .padding(25)
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 30) {
                        
                        // Info Grid - Expanded to show all details
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            InfoBox(icon: "clock.fill", title: "Time", value: event.time)
                            InfoBox(icon: "mappin.and.ellipse", title: "Location", value: event.location)
                            InfoBox(icon: "dollarsign.circle.fill", title: "Entry Fee", value: event.entryFee)
                            InfoBox(icon: "calendar", title: "Date", value: event.date)
                        }
                        
                        Divider()
                        
                        // Description
                        VStack(alignment: .leading, spacing: 15) {
                            Text("About Event")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text(event.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(6)
                        }
                        
                        // Rules - Enhanced Visibility
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Key Information")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 0) {
                                ForEach(Array(event.rules.enumerated()), id: \.offset) { index, rule in
                                    HStack(alignment: .top, spacing: 15) {
                                        Text("\(index + 1)")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .frame(width: 28, height: 28)
                                            .background(Circle().fill(event.color))
                                            
                                        Text(rule)
                                            .font(.subheadline)
                                            .fontWeight(.medium) // Bolder text
                                            .foregroundColor(.primary) // High contrast
                                            .fixedSize(horizontal: false, vertical: true)
                                        Spacer()
                                    }
                                    .padding()
                                    
                                    if index < event.rules.count - 1 {
                                        Divider().padding(.leading, 50)
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(25)
                    .padding(.bottom, 120) // Space for bottom bar
                }
            }
            .edgesIgnoringSafeArea(.top)
            
            // Sticky Bottom Bar (Apple Style)
            VStack(spacing: 0) {
                Divider()
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Entry Fee")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        Text(event.entryFee)
                            .font(.title3)
                            .fontWeight(.heavy)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Action for registration (simulated)
                    }) {
                        Text("Register Now")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 14)
                            .background(Color.black)
                            .cornerRadius(30) // Pill shape
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
                .padding(.bottom, 10) // Safe area handled by background usually, but adding padding
            }
            .background(.ultraThinMaterial)
            .ignoresSafeArea()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoBox: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
