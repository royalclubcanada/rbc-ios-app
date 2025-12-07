import Foundation

// MARK: - API Response Wrappers

struct APIResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T?
    let count: Int?
}

// MARK: - Auth Models

struct User: Codable, Identifiable {
    var id: String { email } // Assuming email is unique or use a real ID if available
    let email: String
    let name: String?
    let phone: String?
    let token: String? // Assuming token comes back in user object or separate
}

struct LoginRequest: Codable {
    let email: String
    let password: String
    let device_type: String
    let device_token: String
}

struct AuthData: Codable {
    let user: User
    let token: String
}

// MARK: - Slot Models

struct Slot: Codable, Identifiable, Hashable {
    var id: String { "\(time)" }
    let time: String // "10:00"
    let isAvailable: Bool
    let price: Double?
}

struct CourtAvailabilityData: Codable {
    // Depending on API structure, this might be a list of slots?
    // Sample response had "data": null, but let's assume valid data structure
    // If data is null in sample, maybe slots are in a separate field or implied?
    // Re-reading prompt sample:
    // { "code": 1, "message": "Slots Available", "data": null, "count": 2 }
    // This looks like a status check? Or maybe I need to infer the slots.
    // I will assume the prompt meant the API *returns* slots in `data` when they exist.
    // Let's define a structure that can hold slots.
    let slots: [Slot]?
}

// MARK: - Location Models

enum Location: String, Codable {
    case mclaughlin = "McLaughlin"
    case mayfield = "Mayfield"
    case etobicoke = "Etobicoke"
    case milton = "Milton"
    
    var courtCount: Int {
        switch self {
        case .mclaughlin: return 9
        case .mayfield: return 6
        case .etobicoke: return 12
        case .milton: return 0 // Coming Soon
        }
    }
}

// MARK: - Booking Models

struct Booking: Codable, Identifiable {
    let id: String
    let date: String
    let slotTime: String
    let status: String // "confirmed", "pending"
    let courtName: String
    // let location: Location? // Could add later
}
