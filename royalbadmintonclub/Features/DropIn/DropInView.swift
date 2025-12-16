import SwiftUI
import Realm
import RealmSwift

struct DropInView: View {
    @ObservedResults(DropInSession.self) var sessions
    @EnvironmentObject var realmManager: RealmManager
    
    @State private var showingPayment = false
    @State private var selectedSessionId: ObjectId?
    @State private var playerName = ""
    @State private var showingDetails = false
    @State private var isJoining = false
    @State private var isLeaving = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Telemetry
    func logEvent(_ eventName: String, parameters: [String: Any] = [:]) {
        print("📊 Telemetry: \(eventName) - \(parameters)")
    }
    
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
                        
                        // Sessions List (Real-time from Realm)
                        ForEach(sessions) { session in
                            DropInCard(
                                session: session,
                                currentUserId: realmManager.currentUser?.id ?? "",
                                joinAction: {
                                    selectedSessionId = session._id
                                    showingPayment = true
                                },
                                leaveAction: {
                                    leaveSession(sessionId: session._id)
                                },
                                detailsAction: {
                                    selectedSessionId = session._id
                                    showingDetails = true
                                }
                            )
                        }
                        
                        if sessions.isEmpty {
                            VStack(spacing: 15) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.system(size: 50))
                                    .foregroundColor(.secondary)
                                Text("No upcoming sessions")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 50)
                        }
                    }
                    .padding(.bottom, 100) // Tab bar spacing
                }
            }
            .sheet(isPresented: $showingPayment) {
                DropInPaymentSheet(name: $playerName) {
                    if let id = selectedSessionId {
                        joinSession(sessionId: id)
                    }
                }
            }
            .sheet(isPresented: $showingDetails) {
                if let id = selectedSessionId,
                   let session = sessions.first(where: { $0._id == id }) {
                    DropInDetailsSheet(session: session)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Drop-In"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func joinSession(sessionId: ObjectId) {
        guard let user = realmManager.currentUser else { return }
        
        isJoining = true
        logEvent("dropin_join", parameters: ["sessionId": sessionId.stringValue])
        
        Task {
            do {
                let result = try await user.functions.joinDropIn([
                    AnyBSON([
                        "sessionId": AnyBSON(sessionId),
                        "userId": AnyBSON(user.id),
                        "userName": AnyBSON(playerName)
                    ])
                ]) as AnyBSON
                
                if let success = result.documentValue?["success"]??.boolValue, success {
                    await MainActor.run {
                        isJoining = false
                        showingPayment = false
                        playerName = ""
                        alertMessage = "Successfully joined session!"
                        showAlert = true
                        logEvent("dropin_join_success")
                    }
                } else {
                    throw NSError(domain: "DropIn", code: 1, userInfo: [
                        NSLocalizedDescriptionKey: result.documentValue?["message"]??.stringValue ?? "Session is full"
                    ])
                }
            } catch {
                await MainActor.run {
                    isJoining = false
                    alertMessage = "Failed to join: \(error.localizedDescription)"
                    showAlert = true
                    logEvent("dropin_join_failed", parameters: ["error": error.localizedDescription])
                }
            }
        }
    }
    
    func leaveSession(sessionId: ObjectId) {
        guard let user = realmManager.currentUser else { return }
        
        isLeaving = true
        logEvent("dropin_leave", parameters: ["sessionId": sessionId.stringValue])
        
        Task {
            do {
                let result = try await user.functions.leaveDropIn([
                    AnyBSON([
                        "sessionId": AnyBSON(sessionId),
                        "userId": AnyBSON(user.id)
                    ])
                ]) as AnyBSON
                
                if let success = result.documentValue?["success"]??.boolValue, success {
                    await MainActor.run {
                        isLeaving = false
                        alertMessage = "Successfully left session"
                        showAlert = true
                        logEvent("dropin_leave_success")
                    }
                } else {
                    throw NSError(domain: "DropIn", code: 2, userInfo: [
                        NSLocalizedDescriptionKey: result.documentValue?["message"]??.stringValue ?? "Failed to leave"
                    ])
                }
            } catch {
                await MainActor.run {
                    isLeaving = false
                    alertMessage = "Failed to leave: \(error.localizedDescription)"
                    showAlert = true
                    logEvent("dropin_leave_failed", parameters: ["error": error.localizedDescription])
                }
            }
        }
    }
}

struct DropInCard: View {
    let session: DropInSession
    let currentUserId: String
    let joinAction: () -> Void
    let leaveAction: () -> Void
    let detailsAction: () -> Void
    
    var isUserJoined: Bool {
        session.players.contains { $0.user_id == currentUserId }
    }
    
    var body: some View {
        Button(action: detailsAction) {
            VStack(spacing: 15) {
                // Time & Status
                HStack {
                    VStack(alignment: .leading) {
                        Text(timeRangeDisplay)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Text(session.status.capitalized)
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
                        Text("\(session.players.count)/\(session.maxCapacity)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
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
                            .frame(width: geo.size.width * CGFloat(session.players.count) / CGFloat(session.maxCapacity), height: 8)
                            .animation(.spring(), value: session.players.count)
                    }
                }
                .frame(height: 8)
                
                // Actions
                if session.status == "open" {
                    HStack {
                        if isUserJoined {
                            Button(action: leaveAction) {
                                Text("Leave Session")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.red.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        } else {
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
        .buttonStyle(.plain)
    }
    
    var timeRangeDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let start = formatter.string(from: session.startTime)
        let end = formatter.string(from: session.endTime)
        return "\(start) - \(end)"
    }
    
    var statusColor: Color {
        switch session.status {
        case "open": return .blue
        case "filled": return .yellow
        case "confirmed": return .green
        case "failed": return .red
        default: return .gray
        }
    }
    
    var statusMessage: String {
        switch session.status {
        case "confirmed": return "Session Confirmed! Courts Booked."
        case "failed": return "Cancelled. Not enough courts."
        case "filled": return "Verifying availability..."
        default: return ""
        }
    }
}

struct DropInDetailsSheet: View {
    let session: DropInSession
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    
                    // Header
                    HStack {
                        Text("Session Players")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.vertical)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach(0..<6, id: \.self) { index in
                            VStack(spacing: 0) {
                                HSCell(index: index, session: session)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal)
                                
                                if index < 5 {
                                    Divider().padding(.leading)
                                }
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Summary Footer
                    Text("\(6 - session.players.count) spots remaining")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground)) // Match List style background
            .navigationTitle(session.timeRangeDisplay)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title3)
                    }
                }
            }
        }
    }
    
    // Helper View for Cell
    func HSCell(index: Int, session: DropInSession) -> some View {
        HStack {
            if index < session.players.count {
                // Active Player
                let player = session.players[index]
                
                Text("\(index + 1)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(player.name)
                        .font(.headline)
                    Text(player.status)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if player.status == "Charged" {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                }
            } else {
                // Placeholder
                Text("\(index + 1)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                Circle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .frame(width: 24, height: 24)
                    .foregroundColor(.secondary.opacity(0.5))
                
                Text("Open Slot")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
                
                Spacer()
                
                Text("Waiting...")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.5))
            }
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
            // Close Button Header
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
            }
            .padding(.top)
            
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
