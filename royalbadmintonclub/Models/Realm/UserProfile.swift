import Foundation
import RealmSwift

class UserProfile: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: String // Map this to the Realm User ID or Email
    @Persisted var email: String
    @Persisted var name: String?
    @Persisted var phone: String?
    @Persisted var deviceToken: String?
    
    // Convenience init
    convenience init(id: String, email: String, name: String? = nil) {
        self.init()
        self._id = id
        self.email = email
        self.name = name
    }
}
