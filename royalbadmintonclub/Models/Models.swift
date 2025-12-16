import Foundation

// MARK: - API Response Wrappers

struct APIResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T?
    let count: Int?
}

// MARK: - Auth Models

struct UserDTO: Codable, Identifiable {
    let _id: String
    var id: String { _id }
    let first_name: String?
    let last_name: String?
    let email: String
    let phone_number: String?
    let profile_pic: String?
    let country_code: String?
    let gender: String?
    let dob: String?
    
    var name: String {
        return [first_name, last_name].compactMap { $0 }.joined(separator: " ")
    }
}

struct LoginResponse: Codable {
    let result: UserDTO
    let auth_token: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
    let device_type: String
    let device_token: String
}

// MARK: - Slot Models

struct SlotDTO: Codable, Identifiable, Hashable {
    let _id: String
    var id: String { _id }
    let slot_time: String // "10:00"
    let price: Double
    let is_active: Bool
    let isAvailableForBooking: Int? // 0 or 1
}

struct CourtDTO: Codable, Identifiable {
    let _id: String
    var id: String { _id }
    let court_name: String
    let venue_id: String
}

// Keeping old Slot for compatibility if needed, but preferable to migrate
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

struct BookingDTO: Codable, Identifiable {
    let _id: String
    var id: String { _id }
    let booking_date: String
    let is_reserved: Bool?
    
    // Nested objects
    let courtDetails: BookingCourtDetails?
    let slotDetails: BookingSlotDetails?
    
    struct BookingCourtDetails: Codable {
        let court_name: String
        let venue_id: String
    }
    
    struct BookingSlotDetails: Codable {
        let slot_time: String
        let price: Double
    }
    
    // Computed properties for UI compatibility
    var date: String { booking_date }
    var slotTime: String { slotDetails?.slot_time ?? "00:00" }
    var courtName: String { courtDetails?.court_name ?? "Unknown Court" }
    var status: String { is_reserved == true ? "Confirmed" : "Pending" } // Simplified logic
    var startTime: Date { 
        // Helper to convert date + slotTime to Date object for conflict checking
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let datePart = String(booking_date.prefix(10)) // "2024-01-30"
        return formatter.date(from: "\(datePart) \(slotTime)") ?? Date()
    }
    var endTime: Date {
        return Calendar.current.date(byAdding: .hour, value: 1, to: startTime) ?? startTime
    }
}

struct AddToCartResponse: Codable {
    let _id: String // This is likely the booking_id
    // Add other fields if necessary
}

struct AddToCartRequest: Codable {
    let court_id: String
    let slot_id: String
    let booking_date: String
    let sport_type: String
}
