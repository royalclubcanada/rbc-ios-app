import Foundation
import Combine

class DropInManager: ObservableObject {
    @Published var sessions: [DropInSession] = []
    
    // Hardcoded slots times
    private let timeSlots = [
        ("17:00", "19:00"),
        ("18:00", "20:00"),
        ("19:00", "21:00"),
        ("20:00", "22:00"),
        ("21:00", "23:00"),
        ("22:00", "00:00")
    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        generateDailySlots()
    }
    
    func generateDailySlots() {
        self.sessions = timeSlots.map { start, end in
            DropInSession(startTime: start, endTime: end)
        }
    }
    
    // Join a session (Payment Hold logic assumed pre-check or handled here)
    func joinSession(sessionId: UUID, playerName: String) {
        guard let index = sessions.firstIndex(where: { $0.id == sessionId }) else { return }
        
        var session = sessions[index]
        if session.isFull { return }
        
        // Add Player (Hold Status)
        let newPlayer = DropInPlayer(name: playerName, status: "Hold")
        sessions[index].players.append(newPlayer)
        
        // Check triggers
        checkActivation(for: index)
    }
    
    // Check if session reached 6 players to activate
    private func checkActivation(for index: Int) {
        var session = sessions[index]
        
        if session.players.count == session.maxPlayers {
            // Trigger Activation Logic
            sessions[index].status = .filled
            verifyAndBook(index: index)
        }
    }
    
    // Check availability and book
    private func verifyAndBook(index: Int) {
        let session = sessions[index]
        let date = Date() // Assuming today for simplicity, or selected date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        // We need 2 courts
        print("Checking availability for Drop-In \(session.startTime)...")
        
        NetworkManager.shared.checkCourtAvailability(date: dateString, slotTime: session.startTime)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] count in
                guard let self = self else { return }
                
                if count >= 2 {
                    // Success! Courts available.
                    print("Success! \(count) courts found. Booking 2 courts...")
                    self.finalizeSuccess(index: index)
                } else {
                    // Fail
                    print("Failed. Only \(count) courts available.")
                    self.finalizeFailure(index: index)
                }
            })
            .store(in: &cancellables)
    }
    
    private func finalizeSuccess(index: Int) {
        sessions[index].status = .confirmed
        // Update players to Charged
        for i in 0..<sessions[index].players.count {
            sessions[index].players[i].status = "Charged"
        }
    }
    
    private func finalizeFailure(index: Int) {
        sessions[index].status = .failed
        // Update players to Refunded/Released
        for i in 0..<sessions[index].players.count {
            sessions[index].players[i].status = "Hold Released"
        }
    }
    
    // Debug Tool: Fill slot almost to capacity
    func simulateFilling(sessionId: UUID) {
        let names = ["Alice", "Bob", "Charlie", "David", "Eve"] // 5 players
        
        for name in names {
            joinSession(sessionId: sessionId, playerName: name)
        }
    }
}
