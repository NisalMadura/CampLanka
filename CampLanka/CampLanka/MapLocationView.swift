//
//  MapLocationView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-07.
//

import SwiftUI
import MapKit

struct LocationData: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let category: String
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
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
        
        // Use DispatchQueue to avoid conflicts with SwiftUI's update cycle
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
}


struct LocationSearchView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    @State private var searchResults: [LocationData] = []
    @State private var selectedLocation: LocationData?
    @State private var showingLocationDetail = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Map(coordinateRegion: $locationManager.region,
                    showsUserLocation: true,
                    annotationItems: searchResults) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        LocationAnnotationView(location: location)
                            .onTapGesture {
                                selectedLocation = location
                                showingLocationDetail = true
                            }
                    }
                }
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    SearchBarMap(text: $searchText, onSubmit: performSearch)
                        .padding()
                    
                    if !searchText.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(searchResults) { location in
                                    LocationRowView(location: location)
                                        .onTapGesture {
                                            selectedLocation = location
                                            showingLocationDetail = true
                                            searchText = ""
                                        }
                                }
                            }
                            .background(Color(.systemBackground))
                        }
                        .frame(maxHeight: 300)
                    }
                }
            }
            .sheet(isPresented: $showingLocationDetail) {
                if let location = selectedLocation {
                    LocationDetailView(location: location)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func performSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = locationManager.region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return }
            
            searchResults = response.mapItems.map { item in
                LocationData(
                    name: item.name ?? "",
                    address: item.placemark.thoroughfare ?? "",
                    coordinate: item.placemark.coordinate,
                    category: item.pointOfInterestCategory?.rawValue ?? ""
                )
            }
        }
    }
}

struct SearchBarMap: View {
    @Binding var text: String
    let onSubmit: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit(onSubmit)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 4)
    }
}

struct LocationAnnotationView: View {
    let location: LocationData
    
    var body: some View {
        VStack {
            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundColor(.red)
            
            Text(location.name)
                .font(.caption)
                .padding(4)
                .background(Color(.systemBackground))
                .cornerRadius(4)
        }
    }
}

struct LocationRowView: View {
    let location: LocationData
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(location.name)
                .font(.headline)
            Text(location.address)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
    }
}

struct LocationDetailView: View {
    let location: LocationData
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLocationInfo: String? = nil
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
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
                        LocationAnnotationView(location: location)
                    }
                }
                .frame(height: 200)
                .cornerRadius(12)
                
                HStack {
                    Button(action: {
                        // Open in Maps
                        let coordinates = location.coordinate
                        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
                        mapItem.name = location.name
                        mapItem.openInMaps()
                    }) {
                        Text("Open in Maps")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // Get directions
                        let coordinates = location.coordinate
                        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
                        mapItem.name = location.name
                        MKMapItem.openMaps(with: [mapItem], launchOptions: [
                            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                        ])
                    }) {
                        Text("Get Directions")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                Button(action: {
                    // Select location
                    selectedLocationInfo = "Name: \(location.name)\nAddress: \(location.address)"
                }) {
                    Text("Select")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                if let info = selectedLocationInfo {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Selected Location:")
                            .font(.headline)
                        Text(info)
                            .font(.body)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

// Preview Provider
struct LocationSearchView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchView()
    }
}
