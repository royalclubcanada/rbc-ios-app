import Foundation
import RealmSwift

class Booking: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var court_id: ObjectId?
    @Persisted var user_id: String // Owner ID
    @Persisted var startTime: Date
    @Persisted var endTime: Date
    @Persisted var status: String = "pending" // pending, confirmed, failed
    @Persisted var courtName: String?
    
    // Additional fields if needed
    
    convenience init(courtId: ObjectId?, userId: String, startTime: Date, endTime: Date, status: String = "pending") {
        self.init()
        self.court_id = courtId
        self.user_id = userId
        self.startTime = startTime
        self.endTime = endTime
        self.status = status
    }
}
