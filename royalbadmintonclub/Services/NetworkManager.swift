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
    
    var currentUser: User? // In memory cache of user
    
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
    func requestFullResponse<T: Codable>(_ endpoint: String, method: String = "GET", body: Encodable? = nil) -> AnyPublisher<APIResponse<T>, Error> {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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
    
    func login(email: String, password: String) -> AnyPublisher<User, Error> {
        let body = LoginRequest(email: email, password: password, device_type: "iOS", device_token: "SIMULATOR_TOKEN") // In real app get real token
        
        return request("/user/login", method: "POST", body: body)
            .handleEvents(receiveOutput: { [weak self] (user: User) in
                // Assuming the API returns the token inside User or as a sibling.
                if let token = user.token {
                    self?.authToken = token
                    self?.currentUser = user
                }
            })
            .eraseToAnyPublisher()
    }
    
    func logout() {
        authToken = nil
        currentUser = nil
        isAuthenticated = false
    }
    
    // MARK: - Feature Methods
    
    func checkCourtAvailability(date: String, slotTime: String) -> AnyPublisher<Int, Error> {
        // GET /user/checkCourtAvailability
        // Response format: { "code": 1, "message": "...", "data": null, "count": 7 }
        
        let path = "/user/checkCourtAvailability?date=\(date)&slotTime=\(slotTime)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
             return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        // Use Void (or similar dummy type) for T since 'data' is null, 
        // but Swift Decodable types must match. 'Data?' in APIResponse handles null.
        // We use String? as a dummy PlaceHolder for T.
        return requestFullResponse(encodedPath, method: "GET")
            .tryMap { (response: APIResponse<String?>) in
                if response.code == 1 {
                     return response.count ?? 0
                } else {
                     throw NetworkError.serverError(response.message)
                }
            }
            .eraseToAnyPublisher()
    }
}
