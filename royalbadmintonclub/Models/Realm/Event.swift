import Foundation
import RealmSwift

class Event: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title: String
    @Persisted var date: Date
    @Persisted var details: String
    @Persisted var imageUrl: String?
    
    convenience init(title: String, date: Date, details: String) {
        self.init()
        self.title = title
        self.date = date
        self.details = details
    }
}
