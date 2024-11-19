import SwiftUI
import MapKit
import Combine

// Location data model
struct LocationData: Identifiable {
    let id = UUID()
    let name: String
    let city: String
    let country: String
    let coordinate: CLLocationCoordinate2D
    let images: [String]
    let category: String
    var isFavorite: Bool = false
    
    // Create from MKMapItem
    init(mapItem: MKMapItem) {
        self.name = mapItem.name ?? ""
        self.city = mapItem.placemark.locality ?? ""
        self.country = mapItem.placemark.country ?? ""
        self.coordinate = mapItem.placemark.coordinate
        self.images = [] // Would be populated from your backend/data source
        self.category = mapItem.pointOfInterestCategory?.rawValue ?? ""
    }
    
    // Custom init for preview/testing
    init(name: String, city: String, country: String, coordinate: CLLocationCoordinate2D, images: [String], category: String) {
        self.name = name
        self.city = city
        self.country = country
        self.coordinate = coordinate
        self.images = images
        self.category = category
    }
}

class LocationSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [LocationData] = []
    @Published var selectedLocation: LocationData?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.4419, longitude: -122.1430),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Debounce search text changes to avoid too many API calls
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                if !searchText.isEmpty {
                    self?.searchLocations(query: searchText)
                } else {
                    self?.searchResults = []
                }
            }
            .store(in: &cancellables)
    }
    
    func searchLocations(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let response = response, error == nil else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self?.searchResults = response.mapItems.map { LocationData(mapItem: $0) }

            }
        }
    }
    
    func selectLocation(_ location: LocationData) {
        selectedLocation = location
        // Update region to center on selected location
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
}

struct LocationSearchView: View {
    @StateObject private var viewModel = LocationSearchViewModel()
    @State private var showingLocationDetail = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Map View
                Map(coordinateRegion: $viewModel.region,
                    showsUserLocation: true,
                    annotationItems: viewModel.selectedLocation.map { [$0] } ?? []) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        MapPinView()
                    }
                }
                .ignoresSafeArea()
                
                // Search UI
                VStack(spacing: 0) {
                    // Search Bar
                    SearchBar(text: $viewModel.searchText)
                        .padding()
                    
                    // Search Results
                    if !viewModel.searchResults.isEmpty {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(viewModel.searchResults) { location in
                                    SearchResultRow(location: location)
                                        .onTapGesture {
                                            viewModel.selectLocation(location)
                                            showingLocationDetail = true
                                            // Clear search after selection
                                            viewModel.searchText = ""
                                            viewModel.searchResults = []
                                        }
                                }
                            }
                            .background(Color(.systemBackground))
                        }
                        .frame(maxHeight: 300)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
            }
            .sheet(isPresented: $showingLocationDetail) {
                if let location = viewModel.selectedLocation {
                    LocationDetailView(location: location)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationBarBackButtonHidden(true)
    }
    
}

struct SearchBart: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search locations...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .autocapitalization(.none)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct SearchResultRow: View {
    let location: LocationData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(location.name)
                .font(.headline)
            Text("\(location.city), \(location.country)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
    }
}

struct MapPinView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundColor(.red)
            
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundColor(.red)
                .offset(y: -5)
        }
    }
}

struct LocationDetailView: View {
    let location: LocationData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(location.name)
                    .font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
            }
            .padding()
            .background(Color.white)
            
            // Location info
            HStack {
                Text("City")
                    .font(.subheadline)
                Text("•")
                Text(location.city)
                Text(location.country)
                    .font(.subheadline)
                Spacer()
                ShareLink(item: "Check out \(location.name)") {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            // Action buttons
            HStack(spacing: 20) {
                ActionButton(title: "Directions", icon: "location.fill", color: .blue) {
                    openInMaps(location: location)
                }
                
                ActionButton(title: "Download", icon: "arrow.down.circle", color: .blue.opacity(0.8)) {
                    // Handle download
                }
                
                ActionButton(title: "More", icon: "ellipsis", color: .gray) {
                    // Handle more options
                }
            }
            .padding()
            
            // Map preview
            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )), annotationItems: [location]) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    MapPinView()
                }
            }
            .frame(height: 200)
            .cornerRadius(10)
            .padding()
            
            Spacer()
        }
    }
    
    private func openInMaps(location: LocationData) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
        mapItem.name = location.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
        }
    }
}

// Preview
struct LocationSearchView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchView()
    }
}
