import SwiftUI
import RealmSwift

struct EventDetailsView: View {
    @ObservedRealmObject var event: Event
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.backgroundLight.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header Image Area
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(colors: [.blue, Color.blue.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            .frame(height: 300)
                            .overlay(
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 120))
                                    .foregroundColor(.white.opacity(0.2))
                                    .offset(x: 50, y: 50)
                            )
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(event.title)
                                .font(.system(size: 36, weight: .heavy))
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            HStack {
                                Image(systemName: "calendar")
                                Text(formattedDate)
                            }
                            .foregroundColor(.white.opacity(0.9))
                            .font(.headline)
                        }
                        .padding(25)
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 30) {
                        
                        // Info Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            InfoBox(icon: "clock.fill", title: "Time", value: formattedTime)
                            InfoBox(icon: "mappin.and.ellipse", title: "Location", value: "TBD")
                            InfoBox(icon: "dollarsign.circle.fill", title: "Entry Fee", value: "TBD")
                            InfoBox(icon: "calendar", title: "Date", value: formattedDate)
                        }
                        
                        Divider()
                        
                        // Description
                        VStack(alignment: .leading, spacing: 15) {
                            Text("About Event")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text(event.details)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(6)
                        }
                    }
                    .padding(25)
                    .padding(.bottom, 120) // Space for bottom bar
                }
            }
            .edgesIgnoringSafeArea(.top)
            
            // Sticky Bottom Bar
            VStack(spacing: 0) {
                Divider()
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Entry Fee")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        Text("TBD")
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
                            .cornerRadius(30)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
                .padding(.bottom, 10)
            }
            .background(.ultraThinMaterial)
            .ignoresSafeArea()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: event.date)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.date)
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
