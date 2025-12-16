import Foundation
import RealmSwift

class DropInPlayer: EmbeddedObject {
    @Persisted var user_id: String
    @Persisted var name: String
    @Persisted var status: String = "hold" // hold, charged, refunded
    
    convenience init(userId: String, name: String, status: String = "hold") {
        self.init()
        self.user_id = userId
        self.name = name
        self.status = status
    }
}

class DropInSession: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var startTime: Date
    @Persisted var endTime: Date
    @Persisted var maxCapacity: Int = 6
    @Persisted var players: List<DropInPlayer>
    @Persisted var status: String = "open" // open, filled, confirmed, failed
    
    convenience init(startTime: Date, endTime: Date, maxCapacity: Int = 6) {
        self.init()
        self.startTime = startTime
        self.endTime = endTime
        self.maxCapacity = maxCapacity
    }
    
    var isFull: Bool {
        return players.count >= maxCapacity
    }
    
    var timeRangeDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let start = formatter.string(from: startTime)
        let end = formatter.string(from: endTime)
        return "\(start) - \(end)"
    }
}
