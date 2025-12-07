import SwiftUI

struct DropInView: View {
    @StateObject private var manager = DropInManager()
    @State private var showingPayment = false
    @State private var selectedSessionId: UUID?
    @State private var playerName = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundLight.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Drop-In Sessions")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                Text("Join a group. Play instantly.")
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        
                        // Sessions List
                        ForEach(manager.sessions) { session in
                            DropInCard(session: session) {
                                selectedSessionId = session.id
                                showingPayment = true
                            } debugAction: {
                                manager.simulateFilling(sessionId: session.id)
                            }
                        }
                    }
                    .padding(.bottom, 100) // Tab bar spacing
                }
            }
            .sheet(isPresented: $showingPayment) {
                // Simplified Payment Sheet for "Hold" simulation
                DropInPaymentSheet(name: $playerName) {
                    if let id = selectedSessionId {
                        manager.joinSession(sessionId: id, playerName: playerName)
                        showingPayment = false
                        playerName = ""
                    }
                }
            }
        }
    }
}

struct DropInCard: View {
    let session: DropInSession
    let joinAction: () -> Void
    let debugAction: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            // Time & Status
            HStack {
                VStack(alignment: .leading) {
                    Text(session.timeRangeDisplay)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(session.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(8)
                }
                Spacer()
                
                // Player Count Badge
                VStack {
                    Text("\(session.playerCount)/\(session.maxPlayers)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Players")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(statusColor)
                        .frame(width: geo.size.width * CGFloat(session.playerCount) / CGFloat(session.maxPlayers), height: 8)
                        .animation(.spring(), value: session.playerCount)
                }
            }
            .frame(height: 8)
            
            // Actions
            if session.status == .open {
                HStack {
                    Button(action: joinAction) {
                        Text(session.isFull ? "Full" : "Join ($15 Hold)")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(session.isFull ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(session.isFull)
                    
                    // Debug Button (Hidden for prod, visible for demo)
                    Button(action: debugAction) {
                        Image(systemName: "person.3.fill")
                            .padding()
                            .background(Color.orange.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            } else {
                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .liquidGlass()
        .padding(.horizontal)
    }
    
    var statusColor: Color {
        switch session.status {
        case .open: return .blue
        case .filled: return .yellow
        case .confirmed: return .green
        case .failed: return .red
        }
    }
    
    var statusMessage: String {
        switch session.status {
        case .confirmed: return "Session Confirmed! Courts Booked."
        case .failed: return "Cancelled. Not enough courts."
        case .filled: return "Verifying availability..."
        default: return ""
        }
    }
}

// Simple Payment Sheet
struct DropInPaymentSheet: View {
    @Binding var name: String
    let onPay: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Secure Hold")
                .font(.headline)
            
            Text("We will place a temporary hold of $15. You will only be charged if the session fills up (6 players).")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
            
            TextField("Your Name", text: $name)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            Button(action: onPay) {
                Text("Authorize Hold")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
            .disabled(name.isEmpty)
        }
        .padding()
    }
}
