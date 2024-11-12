import Foundation

// API Response Model
struct BookingLocation: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
    let image_url: String
    let city_name: String
    let region: String
    let label: String
    let dest_id: String
    
    // Computing a price range for demo purposes
    var estimatedPrice: Double {
        // Generate a random price between 100 and 300
        return Double.random(in: 100...300)
    }
    
    // Convert to standardized Hotel format
    func toHotel() -> Hotel {
        return Hotel(
            name: name,
            latitude: latitude,
            longitude: longitude,
            starRating: Int.random(in: 3...5), // Demo rating
            price: estimatedPrice,
            address: "\(city_name), \(region)",
            images: [image_url]
        )
    }
}

struct Hotel: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
    let starRating: Int
    let price: Double
    let address: String
    let images: [String]
}

class APIManager {
    static let shared = APIManager()
    
    private init() {}
    
    func fetchGlampingSriLanka(completion: @escaping ([Hotel]?, Error?) -> Void) {
        let headers = [
            "x-rapidapi-key": "e27df7cf64msh047a2b2eb7d5486p130a97jsndb1adc791a0a",
            "x-rapidapi-host": "booking-com.p.rapidapi.com"
        ]
        
        let urlString = "https://booking-com.p.rapidapi.com/v1/hotels/locations?locale=en-gb&name=glamping%20sri%20lanka"
        
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "com.example.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, NSError(domain: "com.example.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                }
                return
            }
            
            do {
                // First decode as array of BookingLocation
                let locations = try JSONDecoder().decode([BookingLocation].self, from: data)
                
                // Convert BookingLocation array to Hotel array
                let hotels = locations.map { $0.toHotel() }
                
                DispatchQueue.main.async {
                    completion(hotels, nil)
                }
            } catch {
                print("Decoding error:", error)
                print("Raw response:", String(data: data, encoding: .utf8) ?? "Unable to convert data to string")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        
        dataTask.resume()
    }
}
