import Foundation
import Combine

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    private let baseURL = "https://api.royalbadmintonclub.com:4000/api"
    
    @Published var isAuthenticated = false
    
    // Simple token storage
    var authToken: String? {
        get { UserDefaults.standard.string(forKey: "authToken") }
        set {
            UserDefaults.standard.set(newValue, forKey: "authToken")
            isAuthenticated = (newValue != nil)
        }
    }
    
    var currentUser: UserDTO? // In memory cache of user
    
    private init() {
        self.isAuthenticated = (authToken != nil)
    }
    
    // MARK: - Generic Request
    
    enum NetworkError: Error, LocalizedError {
        case invalidURL
        case decodingError
        case serverError(String)
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid URL"
            case .decodingError: return "Failed to parse response"
            case .serverError(let msg): return msg
            case .unknown: return "An unknown error occurred"
            }
        }
    }
    
    // Generic Request returning simple object
    func request<T: Codable>(_ endpoint: String, method: String = "GET", body: Encodable? = nil) -> AnyPublisher<T, Error> {
        // For simple request, we can reuse requestFullResponse but we won't pass query items here for now
        // If needed we can expand this signature too
        let publisher: AnyPublisher<APIResponse<T>, Error> = requestFullResponse(endpoint, method: method, body: body)
        
        return publisher
            .tryMap { response in
                if response.code == 1 {
                    if let data = response.data {
                        return data
                    } else {
                        throw NetworkError.serverError("No data returned")
                    }
                } else {
                    throw NetworkError.serverError(response.message)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // Generic Request returning full APIResponse (useful when data is null but count exists)
    func requestFullResponse<T: Codable>(
        _ endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        queryItems: [URLQueryItem]? = nil
    ) -> AnyPublisher<APIResponse<T>, Error> {
        
        var components = URLComponents(string: "\(baseURL)\(endpoint)")
        if let queryItems = queryItems {
            components?.queryItems = queryItems
        }
        
        guard let url = components?.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            // Postman uses "authtoken", NOT "Authorization: Bearer ..."
            request.addValue(token, forHTTPHeaderField: "authtoken")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                return Fail(error: error).eraseToAnyPublisher()
            }
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: APIResponse<T>.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Auth Methods
    
    func login(email: String, password: String) -> AnyPublisher<UserDTO, Error> {
        // Device token is hardcoded for now, in real app use Firebase Messaging token
        let body = LoginRequest(email: email, password: password, device_type: "I", device_token: "SIMULATOR_TOKEN")
        
        return request("/user/login", method: "POST", body: body)
            .handleEvents(receiveOutput: { [weak self] (response: LoginResponse) in
                self?.authToken = response.auth_token
                self?.currentUser = response.result
            })
            .map { $0.result }
            .eraseToAnyPublisher()
    }
    
    func logout() {
        authToken = nil
        currentUser = nil
        isAuthenticated = false
    }
    
    func getProfile() -> AnyPublisher<UserDTO, Error> {
        return request("/user/profile", method: "GET")
            .handleEvents(receiveOutput: { [weak self] (user: UserDTO) in
                self?.currentUser = user
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Booking Methods
    
    // Fetch courts for a specific venue, sport, and date
    func fetchCourts(venueId: String, sportType: Int = 1, date: String) -> AnyPublisher<[CourtDTO], Error> {
        // Query params
        let queryItems = [
            URLQueryItem(name: "venue_id", value: venueId),
            URLQueryItem(name: "sport_type", value: String(sportType)),
            URLQueryItem(name: "date", value: date)
        ]
        
        return requestFullResponse("/user/court", method: "GET", queryItems: queryItems)
            .tryMap { (response: APIResponse<[CourtDTO]>) -> [CourtDTO] in
                if response.code == 1 {
                    return response.data ?? []
                } else {
                    throw NetworkError.serverError(response.message)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // Fetch slots for a specific court and date
    func fetchSlots(courtId: String, date: String) -> AnyPublisher<[SlotDTO], Error> {
        let queryItems = [
            URLQueryItem(name: "court_id", value: courtId),
            URLQueryItem(name: "date", value: date)
        ]
        
        return requestFullResponse("/user/slot", method: "GET", queryItems: queryItems)
            .tryMap { (response: APIResponse<[SlotDTO]>) -> [SlotDTO] in
                if response.code == 1 {
                    return response.data ?? []
                } else {
                    throw NetworkError.serverError(response.message)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // Add to cart (Create a pending booking)
    func addToCart(courtId: String, slotId: String, bookingDate: String, sportType: String = "1") -> AnyPublisher<AddToCartResponse, Error> {
        let body = AddToCartRequest(
            court_id: courtId,
            slot_id: slotId,
            booking_date: bookingDate,
            sport_type: sportType
        )
        
        // This endpoint likely returns the created booking/cart item in 'data'
        return request("/user/addToCart", method: "POST", body: body)
            .eraseToAnyPublisher()
    }
    
    // Confirm a booking
    func confirmBooking(bookingId: String) -> AnyPublisher<Void, Error> {
        let body = ["booking_id": bookingId]
        return requestVoid("/user/confirmBooking", method: "PUT", bodyDict: body)
    }
    
    // Fetch User Bookings
    func fetchBookings(listingFor: Int = 1) -> AnyPublisher<[BookingDTO], Error> {
        // listing_for: 1=Upcoming, 2=Completed, 3=Ongoing, 4=Cancelled
        let queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "limit", value: "50"), // Fetch more
            URLQueryItem(name: "listing_for", value: String(listingFor))
        ]
        
        return requestFullResponse("/user/myBooking", method: "GET", queryItems: queryItems)
            .tryMap { (response: APIResponse<[BookingDTO]>) -> [BookingDTO] in
                if response.code == 1 {
                    return response.data ?? []
                } else {
                    throw NetworkError.serverError(response.message)
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Feature Methods
    
    func checkCourtAvailability(date: String, slotTime: String) -> AnyPublisher<Int, Error> {
        // GET /user/checkCourtAvailability
        let queryItems = [
            URLQueryItem(name: "date", value: date),
            URLQueryItem(name: "slotTime", value: slotTime)
        ]

        return requestFullResponse("/user/checkCourtAvailability", method: "GET", queryItems: queryItems)
             .tryMap { (response: APIResponse<String?>) in // Use String? as dummy place holder
                 if response.code == 1 {
                      return response.count ?? 0
                 } else {
                      throw NetworkError.serverError(response.message)
                 }
             }
             .eraseToAnyPublisher()
    }
    
    // MARK: - Helpers
    
    // Helper to send [String: Any] body and ignore response data, just check code=1
    private func requestVoid(_ endpoint: String, method: String, bodyDict: [String: Any]) -> AnyPublisher<Void, Error> {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.setValue(token, forHTTPHeaderField: "authtoken") // Postman uses "authtoken", not Bearer
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyDict)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: APIResponse<String?>.self, decoder: JSONDecoder())
            .tryMap { response in
                if response.code == 1 {
                    return ()
                } else {
                    throw NetworkError.serverError(response.message)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
