import Foundation

enum DropInStatus: String, Codable {
    case open = "Open"
    case filled = "Filled"     // 6 players joined
    case confirmed = "Confirmed" // Courts booked
    case failed = "Failed"     // Not enough courts
}

struct DropInPlayer: Identifiable, Codable {
    var id = UUID()
    let name: String
    var status: String // "Hold", "Charged", "Refunded"
}

struct DropInSession: Identifiable, Codable {
    var id = UUID()
    let startTime: String // e.g., "17:00"
    let endTime: String   // e.g., "19:00"
    var players: [DropInPlayer] = []
    let maxPlayers: Int = 6
    var status: DropInStatus = .open
    
    var timeRangeDisplay: String {
        return "\(startTime) - \(endTime)"
    }
    
    var playerCount: Int {
        return players.count
    }
    
    var isFull: Bool {
        return players.count >= maxPlayers
    }
}
