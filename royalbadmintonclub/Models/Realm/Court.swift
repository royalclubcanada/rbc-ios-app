import Foundation
import RealmSwift

class Court: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String
    @Persisted var courtNumber: Int
    @Persisted var location: String // "McLaughlin", etc.
    
    // We can also embed availabilities if we want, but usually availability is calculated or separate.
    // However, users asked for "Courts availability (based on selected date/time)"
    // Typically Realm syncs objects. If availability is highly dynamic, maybe it's better fetched or computed.
    // But requirement says "Subscriptions for... Courts availability".
    // This implies `Court` objects might have `isAvailable` status or we sync `Booking`s and infer availability.
    // Syncing `Booking`s and inferring availability is the standard Realm pattern.
    
    convenience init(name: String, courtNumber: Int, location: String) {
        self.init()
        self.name = name
        self.courtNumber = courtNumber
        self.location = location
    }
}
