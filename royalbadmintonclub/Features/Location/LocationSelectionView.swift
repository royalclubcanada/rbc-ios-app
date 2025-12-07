import SwiftUI

struct LocationSelectionView: View {
    @EnvironmentObject var network: NetworkManager
    @Binding var selectedLocation: Location?
    
    // Smooth transition to main app
    var body: some View {
        ZStack {
            Color.backgroundLight.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Select Location")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .padding(.top, 50)
                
                VStack(spacing: 20) {
                    LocationCard(
                        title: "McLaughlin",
                        subtitle: "9 Courts Available",
                        image: "map.fill", // Placeholder system icon
                        color: .blue
                    )
                    .onTapGesture {
                        withAnimation {
                            selectedLocation = .mclaughlin
                        }
                    }
                    
                    LocationCard(
                        title: "Mayfield",
                        subtitle: "6 Courts Available",
                        image: "sportscourt.fill",
                        color: .purple
                    )
                    .onTapGesture {
                        withAnimation {
                            selectedLocation = .mayfield
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

struct LocationCard: View {
    let title: String
    let subtitle: String
    let image: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: image)
                .font(.system(size: 40))
                .foregroundColor(.white)
                .frame(width: 80, height: 80)
                .background(color.opacity(0.8))
                .cornerRadius(20)
                .shadow(color: color.opacity(0.4), radius: 10, x: 0, y: 5)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 10)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .liquidGlass()
    }
}
