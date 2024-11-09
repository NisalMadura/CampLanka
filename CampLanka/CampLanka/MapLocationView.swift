//
//  MapLocationView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-07.
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - Data Models
struct PlaceDetails: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let category: String
    let placeId: String?
}

struct LocationData: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let category: String
}

// MARK: - Google Places API Response Models
struct GooglePlacesResponse: Codable {
    let results: [PlaceResult]
}

struct PlaceResult: Codable {
    let name: String
    let placeId: String
    let geometry: Geometry
    let vicinity: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case placeId = "place_id"
        case geometry
        case vicinity
    }
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

// MARK: - Location Search Manager
class LocationSearchManager: ObservableObject {
    private let googlePlacesApiKey = "AIzaSyB-vj0d4Zq80Dt4QuKnwO1c1rJbZ0xjE9k" // Replace with your API key
    
    func searchNearbyCampsites(location: CLLocationCoordinate2D, radius: Int = 50000) async -> [PlaceDetails] {
        let baseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        let queryItems = [
            URLQueryItem(name: "key", value: googlePlacesApiKey),
            URLQueryItem(name: "location", value: "\(location.latitude),\(location.longitude)"),
            URLQueryItem(name: "radius", value: "\(radius)"),
            URLQueryItem(name: "keyword", value: "camping site")
        ]
        
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else { return [] }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let results = try decoder.decode(GooglePlacesResponse.self, from: data)
            
            // Debug: Print out the number of results received
            print("Received \(results.results.count) places from Google Places API")
            
            return results.results.map { result in
                PlaceDetails(
                    name: result.name,
                    address: result.vicinity,
                    coordinate: CLLocationCoordinate2D(
                        latitude: result.geometry.location.lat,
                        longitude: result.geometry.location.lng
                    ),
                    category: "Camping",
                    placeId: result.placeId
                )
            }
        } catch {
            print("Error fetching places: \(error)")
            return []
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718), // Sri Lanka's center
        span: MKCoordinateSpan(latitudeDelta: 4, longitudeDelta: 4)
    )
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }
}

// MARK: - Views
struct LocationSearchView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var places: [PlaceDetails] = []
    @State private var selectedLocation: PlaceDetails?
    @State private var showingLocationDetail = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Map(coordinateRegion: $locationManager.region,
                    showsUserLocation: true,
                    annotationItems: places) { place in
                    MapAnnotation(coordinate: place.coordinate) {
                        CampingSiteAnnotationView(name: place.name)
                            .onTapGesture {
                                selectedLocation = place
                                showingLocationDetail = true
                            }
                    }
                }
                .ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                        .padding()
                        .background(Color(.systemBackground))
                }
            }
            .sheet(isPresented: $showingLocationDetail) {
                if let location = selectedLocation {
                    LocationDetailView(location: LocationData(
                        name: location.name,
                        address: location.address,
                        coordinate: location.coordinate,
                        category: location.category
                    ))
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadHardcodedCampsites()
            }
        }
    }
    
    private func loadHardcodedCampsites() {
        // Adding hard-coded campsite locations
        places = [
            PlaceDetails(name: "Campsite 1", address: "Address 1", coordinate: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612), category: "Camping", placeId: nil),
            PlaceDetails(name: "Campsite 2", address: "Address 2", coordinate: CLLocationCoordinate2D(latitude: 6.9240, longitude: 79.8600), category: "Camping", placeId: nil),
            PlaceDetails(name: "Campsite 3", address: "Address 3", coordinate: CLLocationCoordinate2D(latitude: 7.2906, longitude: 80.6337), category: "Camping", placeId: nil),
            PlaceDetails(name: "Campsite 4", address: "Address 4", coordinate: CLLocationCoordinate2D(latitude: 6.0535, longitude: 80.2210), category: "Camping", placeId: nil),
            PlaceDetails(name: "Campsite 5", address: "Address 5", coordinate: CLLocationCoordinate2D(latitude: 8.3114, longitude: 80.4037), category: "Camping", placeId: nil),
            PlaceDetails(name: "Campsite 6", address: "Address 6", coordinate: CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718), category: "Camping", placeId: nil),
            PlaceDetails(name: "Campsite 7", address: "Address 7", coordinate: CLLocationCoordinate2D(latitude: 7.8722, longitude: 79.8612), category: "Camping", placeId: nil),
            PlaceDetails(name: "Campsite 8", address: "Address 8", coordinate: CLLocationCoordinate2D(latitude: 6.9278, longitude: 79.8538), category: "Camping", placeId: nil),
            PlaceDetails(name: "Campsite 9", address: "Address 9", coordinate: CLLocationCoordinate2D(latitude: 6.9320, longitude: 79.8438), category: "Camping", placeId: nil),
            PlaceDetails(name: "Campsite 10", address: "Address 10", coordinate: CLLocationCoordinate2D(latitude: 7.0000, longitude: 79.9400), category: "Camping", placeId: nil)
        ]
        
        // Debug: Print loaded hard-coded places
        print("Loaded \(places.count) hard-coded campsites for map annotations")
    }
}


struct CampingSiteAnnotationView: View {
    let name: String
    
    var body: some View {
        VStack {
            Image(systemName: "tent.fill")
                .font(.title)
                .foregroundColor(.red)
            
            Text(name)
                .font(.caption)
                .padding(4)
                .background(Color(.systemBackground))
                .cornerRadius(4)
        }
    }
}

struct LocationDetailView: View {
    let location: LocationData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text(location.name)
                .font(.title)
                .bold()
            
            Text(location.address)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )), annotationItems: [location]) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    CampingSiteAnnotationView(name: location.name)
                }
            }
            .frame(height: 200)
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
        .navigationBarItems(trailing: Button("Done") {
            dismiss()
        })
    }
}

// MARK: - Preview Provider
struct LocationSearchView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchView()
    }
}
