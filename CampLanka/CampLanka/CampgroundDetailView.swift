//
//  CampgroundDetailView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-12.
//

import SwiftUI
import FirebaseFirestore
import MapKit
import CoreLocation
import FirebaseAuth


struct CampgroundBase: Identifiable {
    let id: String
    let name: String
    let location: String
    let imageUrl: String
    let likes: Int
    let rating: Double
    var isFavorite: Bool
    let coordinates: CLLocationCoordinate2D
    
    init?(id: String, data: [String: Any]) {
        self.id = id
        guard let name = data["name"] as? String,
              let location = data["location"] as? String,
              let imageUrl = data["imageUrl"] as? String,
              let likes = data["likes"] as? Int,
              let rating = data["rating"] as? Double,
              let coordinates = data["coordinates"] as? GeoPoint else{
            return nil
        }
        self.name = name
        self.location = location
        self.imageUrl = imageUrl
        self.likes = likes
        self.rating = rating
        self.isFavorite = data["isFavorite"] as? Bool ?? false
        self.coordinates = CLLocationCoordinate2D(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude
        )
    }
}
struct WeatherInfo: Identifiable {
    let id = UUID()
    let date: Date
    let temperature: Double
    let condition: WeatherCondition
    let precipitation: Int
    let windSpeed: Double
    let humidity: Int
}

enum WeatherCondition: String {
    case sunny = "sun.max.fill"
    case cloudy = "cloud.fill"
    case rainy = "cloud.rain.fill"
    case partlyCloudy = "cloud.sun.fill"
    case thunderstorm = "cloud.bolt.rain.fill"
}

class WeatherViewModel: ObservableObject {
    @Published var currentWeather: WeatherInfo?
    @Published var hourlyForecast: [WeatherInfo] = []
    @Published var dailyForecast: [WeatherInfo] = []
    @Published var isLoading = false
    
    func loadMockWeather() {
        
        isLoading = true
        
        
        currentWeather = WeatherInfo(
            date: Date(),
            temperature: 28,
            condition: .sunny,
            precipitation: 10,
            windSpeed: 12,
            humidity: 65
        )
        
        
        hourlyForecast = [
            WeatherInfo(date: Date().addingTimeInterval(3600), temperature: 29, condition: .sunny, precipitation: 10, windSpeed: 13, humidity: 63),
            WeatherInfo(date: Date().addingTimeInterval(7200), temperature: 30, condition: .partlyCloudy, precipitation: 20, windSpeed: 14, humidity: 60),
            WeatherInfo(date: Date().addingTimeInterval(10800), temperature: 27, condition: .cloudy, precipitation: 40, windSpeed: 15, humidity: 70),
            WeatherInfo(date: Date().addingTimeInterval(14400), temperature: 25, condition: .rainy, precipitation: 60, windSpeed: 18, humidity: 75)
        ]
        
        
        dailyForecast = [
            WeatherInfo(date: Date().addingTimeInterval(86400), temperature: 27, condition: .partlyCloudy, precipitation: 30, windSpeed: 14, humidity: 68),
            WeatherInfo(date: Date().addingTimeInterval(172800), temperature: 26, condition: .rainy, precipitation: 70, windSpeed: 16, humidity: 78),
            WeatherInfo(date: Date().addingTimeInterval(259200), temperature: 28, condition: .sunny, precipitation: 10, windSpeed: 12, humidity: 65)
        ]
        
        isLoading = false
    }
}

struct ReservationInfo {
    let isReservationRequired: Bool
    let policy: String
    let maxStayDays: Int
}


struct ContactInfo {
    let office: String
    let phone: String
    let emergency: String
    let email: String
}


struct AccessMethod: Identifiable {
    var id: UUID = UUID()
    let type: AccessType
    let description: String
    
    enum AccessType: String {
        case hikeIn = "hikeIn"
        case driveIn = "driveIn"
        case walkIn = "walkIn"
    }
}


struct ConnectivityOption: Identifiable {
    var id: UUID = UUID()
    let type: ConnectivityType
    let provider: String?
    
    enum ConnectivityType: String {
        case wifi = "wifi"
        case noWifi = "noWifi"
        case cellular = "cellular"
    }
}


struct SiteType: Identifiable {
    var id: UUID = UUID()
    let type: SiteTypeOption
    
    enum SiteTypeOption {
        case tent
        case rv
        case cabin
        case groupSite
    }
}


struct Feature: Identifiable {
    var id: UUID = UUID()
    let type: FeatureType
    
    enum FeatureType {
        case firewood
        case drinkingWater
        case parking
    }
}
struct CampgroundDetail {
    var base: CampgroundBase
    let numberOfReviews: Int
    let servicesCount: Int
    let distanceInMeters: Int
    let description: String
    let reservationInfo: ReservationInfo
    let contactInfo: ContactInfo
    let accessMethods: [AccessMethod]
    let connectivity: [ConnectivityOption]
    let siteTypes: [SiteType]
    let features: [Feature]
    
    init?(id: String, baseData: [String: Any], detailData: [String: Any]) {
        
        guard let base = CampgroundBase(id: id, data: baseData) else {
            return nil
        }
        self.base = base
        
        
        self.numberOfReviews = detailData["numberOfReviews"] as? Int ?? 0
        self.servicesCount = detailData["servicesCount"] as? Int ?? 0
        self.distanceInMeters = detailData["distanceInMeters"] as? Int ?? 0
        self.description = detailData["description"] as? String ?? ""
        
        
        if let reservationData = detailData["reservationInfo"] as? [String: Any] {
            self.reservationInfo = ReservationInfo(
                isReservationRequired: reservationData["isReservationRequired"] as? Bool ?? false,
                policy: reservationData["policy"] as? String ?? "",
                maxStayDays: reservationData["maxStayDays"] as? Int ?? 0
            )
        } else {
            self.reservationInfo = ReservationInfo(isReservationRequired: false, policy: "", maxStayDays: 0)
        }
        
        
        if let contactData = detailData["contactInfo"] as? [String: Any] {
            self.contactInfo = ContactInfo(
                office: contactData["office"] as? String ?? "",
                phone: contactData["phone"] as? String ?? "",
                emergency: contactData["emergency"] as? String ?? "",
                email: contactData["email"] as? String ?? ""
            )
        } else {
            self.contactInfo = ContactInfo(office: "", phone: "", emergency: "", email: "")
        }
        
        
        if let accessData = detailData["accessMethods"] as? [[String: Any]] {
            self.accessMethods = accessData.map { data in
                AccessMethod(
                    type: AccessMethod.AccessType(rawValue: data["type"] as? String ?? "") ?? .walkIn,
                    description: data["description"] as? String ?? ""
                )
            }
        } else {
            self.accessMethods = []
        }
        
        
        if let connectivityData = detailData["connectivity"] as? [[String: Any]] {
            self.connectivity = connectivityData.map { data in
                ConnectivityOption(
                    type: ConnectivityOption.ConnectivityType(rawValue: data["type"] as? String ?? "") ?? .noWifi,
                    provider: data["provider"] as? String
                )
            }
        } else {
            self.connectivity = []
        }
        
        
        self.siteTypes = [SiteType(type: .tent)]
        self.features = [
            Feature(type: .firewood),
            Feature(type: .drinkingWater),
            Feature(type: .parking)
        ]
    }
}


class CampgroundDetailViewModel: ObservableObject {
    private let db = Firestore.firestore()
    @Published var campgroundDetail: CampgroundDetail?
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var showLoginAlert = false
    @Published var showWishlistView = false
    
    init() {
        
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let id = self?.campgroundDetail?.base.id {
                self?.checkWishlistStatus(for: id)
            }
        }
    }
    
    func fetchCampgroundDetail(id: String) {
        isLoading = true
        errorMessage = nil
        
        db.collection("campgrounds").document(id).getDocument { [weak self] baseSnapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
                return
            }
            
            guard let baseData = baseSnapshot?.data() else {
                DispatchQueue.main.async {
                    self?.errorMessage = "Campground not found"
                    self?.isLoading = false
                }
                return
            }
            
            self?.db.collection("campgrounds").document(id).getDocument { detailSnapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        self?.isLoading = false
                        return
                    }
                    
                    guard let detailData = detailSnapshot?.data() else {
                        self?.errorMessage = "Details not found"
                        self?.isLoading = false
                        return
                    }
                    
                    if let campgroundDetail = CampgroundDetail(id: id, baseData: baseData, detailData: detailData) {
                        self?.campgroundDetail = campgroundDetail
                        self?.checkWishlistStatus(for: id)
                    }
                    
                    self?.isLoading = false
                }
            }
        }
    }
    
    private func checkWishlistStatus(for campgroundId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            if var detail = campgroundDetail {
                detail.base.isFavorite = false
                campgroundDetail = detail
            }
            return
        }
        
        db.collection("users").document(userId)
            .collection("wishlist")
            .document(campgroundId)
            .getDocument { [weak self] snapshot, error in
                if let exists = snapshot?.exists {
                    DispatchQueue.main.async {
                        if var detail = self?.campgroundDetail {
                            detail.base.isFavorite = exists
                            self?.campgroundDetail = detail
                        }
                    }
                }
            }
    }
    
    func handleFavoriteButtonTap() {
        if Auth.auth().currentUser != nil {
            toggleFavorite()
        } else {
            showLoginAlert = true
        }
    }
    
    func toggleFavorite() {
        guard let detail = campgroundDetail else { return }
        guard let userId = Auth.auth().currentUser?.uid else {
            showLoginAlert = true
            return
        }
        
        let newValue = !detail.base.isFavorite
        let wishlistRef = db.collection("users").document(userId).collection("wishlist")
        
        if newValue {
            // Add to wishlist
            wishlistRef.document(detail.base.id).setData([
                "addedAt": FieldValue.serverTimestamp(),
                "campgroundId": detail.base.id,
                "name": detail.base.name,
                "location": detail.base.location,
                "imageUrl": detail.base.imageUrl,
                "rating": detail.base.rating
            ])
        } else {
            
            wishlistRef.document(detail.base.id).delete()
        }
        
        
        DispatchQueue.main.async {
            if var updatedDetail = self.campgroundDetail {
                updatedDetail.base.isFavorite = newValue
                self.campgroundDetail = updatedDetail
            }
        }
    }
}


struct CampgroundDetailView: View {
    @StateObject private var viewModel = CampgroundDetailViewModel()
    @State private var selectedTab = 0
    let campgroundId: String
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            }    else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if let campground = viewModel.campgroundDetail {
                VStack(alignment: .leading, spacing: 0) {
                    
                    AsyncImage(url: URL(string: campground.base.imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .frame(height: 250)
                    .clipped()
                    
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(campground.base.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.handleFavoriteButtonTap()
                            }) {
                                Image(systemName: campground.base.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(campground.base.isFavorite ? .red : .gray)
                                    .font(.title2)
                            }
                        }
                        
                        Text(campground.base.location)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", campground.base.rating))
                            Text("(\(campground.numberOfReviews) Reviews)")
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: { }) {
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Add to plan")
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    
                    
                    tabBar(campground: campground)
                    
                    
                    tabContent(campground: campground)
                        .padding(.horizontal)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Sign in Required", isPresented: $viewModel.showLoginAlert) {
            Button("Sign In") {
                viewModel.showWishlistView = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please sign in to add items to your wishlist")
        }
        .sheet(isPresented: $viewModel.showWishlistView) {
            NavigationView {
                SignInView()
            }
        }
        .onAppear {
            viewModel.fetchCampgroundDetail(id: campgroundId)
        }
    }
    
    
    private func tabBar(campground: CampgroundDetail) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                TabButton(title: "Overview", count: nil, isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                
                TabButton(title: "Services", count: nil, isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                
                TabButton(title: "Location", count: nil, isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                
                TabButton(title: "Reviews", count: nil, isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
                
                TabButton(title: "Weather", count: nil, isSelected: selectedTab == 4) {
                    selectedTab = 4
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func tabContent(campground: CampgroundDetail) -> some View {
        VStack(alignment: .leading, spacing: 29) {
            switch selectedTab {
            case 0:
                OverviewTab(campground: campground)
            case 1:
                ServicesTab(campground: campground)
            case 2:
                LocationTab(campground: campground)
            case 3:
                ReviewsTab(campground: campground)
            case 4:
                WeatherTab(campground: campground)
            default:
                EmptyView()
            }
        }
        .padding(.top)
    }
}

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            /* Image(systemName: "chevron.left")
             .foregroundColor(.primary)*/
        }
    }
}

struct TabButton: View {
    let title: String
    let count: Int?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                if let count = count {
                    Text("\(count)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Rectangle()
                    .fill(isSelected ? Color.green : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.green)
            content
        }
    }
}

struct CampgroundContactRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(value)
        }
    }
}


struct OverviewTab: View {
    let campground: CampgroundDetail
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            SectionView(title: "About") {
                Text(campground.description)
                    .lineSpacing(4)
            }
            
            
            SectionView(title: "Reservation Info") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reservation Required: \(campground.reservationInfo.isReservationRequired ? "Yes" : "No")")
                    Text(campground.reservationInfo.policy)
                    Text("Maximum Stay: \(campground.reservationInfo.maxStayDays) days")
                }
            }
            
            
            SectionView(title: "Contact Information") {
                VStack(alignment: .leading, spacing: 12) {
                    CampgroundContactRow(title: "Park Office", value: campground.contactInfo.office)
                    CampgroundContactRow(title: "Phone", value: campground.contactInfo.phone)
                    CampgroundContactRow(title: "Emergency Contact", value: campground.contactInfo.emergency)
                    CampgroundContactRow(title: "Email", value: campground.contactInfo.email)
                }
            }
            
            
            SectionView(title: "Access") {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(campground.accessMethods) { method in
                        HStack(spacing: 12) {
                            Image(systemName: accessIcon(for: method.type))
                                .foregroundColor(.green)
                            Text(method.description)
                        }
                    }
                }
            }
            
            
            SectionView(title: "Stay Connected") {
                HStack(spacing: 24) {
                    ForEach(campground.connectivity) { option in
                        connectivityView(for: option)
                    }
                }
            }
            
            
            SectionView(title: "Site Types") {
                HStack(spacing: 24) {
                    ForEach(campground.siteTypes) { siteType in
                        siteTypeView(for: siteType)
                    }
                }
            }
            
            
            SectionView(title: "Features") {
                HStack(spacing: 24) {
                    ForEach(campground.features) { feature in
                        featureView(for: feature)
                    }
                }
            }
        }
    }
    
    private func accessIcon(for type: AccessMethod.AccessType) -> String {
        switch type {
        case .hikeIn: return "figure.hiking"
        case .driveIn: return "car"
        case .walkIn: return "figure.walk"
        }
    }
    
    private func connectivityView(for option: ConnectivityOption) -> some View {
        HStack(spacing: 8) {
            Image(systemName: option.type == .noWifi ? "wifi.slash" : "wifi")
                .foregroundColor(.green)
            Text(option.type == .noWifi ? "No WIFI" : option.provider ?? "")
        }
    }
    
    private func siteTypeView(for siteType: SiteType) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "tent")
                .foregroundColor(.green)
            Text("Tent")
        }
    }
    
    private func featureView(for feature: Feature) -> some View {
        HStack(spacing: 8) {
            Image(systemName: featureIcon(for: feature.type))
                .foregroundColor(.green)
            Text(featureText(for: feature.type))
        }
    }
    
    private func featureIcon(for type: Feature.FeatureType) -> String {
        switch type {
        case .firewood: return "flame"
        case .drinkingWater: return "drop"
        case .parking: return "p.square"
        }
    }
    
    private func featureText(for type: Feature.FeatureType) -> String {
        switch type {
        case .firewood: return "Firewood"
        case .drinkingWater: return "Drinking Water"
        case .parking: return "Parking"
        }
    }
}


struct ServiceCard: Identifiable {
    let id = UUID()
    let title: String
    let contactNumber: String
    let imageUrl: String
    let isVerified: Bool
    let isFeatured: Bool
}

struct ServicesTab: View {
    let campground: CampgroundDetail
    
    
    let services = [
        ServiceCard(
            title: "Tent Rental",
            contactNumber: "+94 777 123456",
            imageUrl: "serviceimg1",
            isVerified: true,
            isFeatured: true
        ),
        ServiceCard(
            title: "Local Guide Services",
            contactNumber: "+94 777 123456",
            imageUrl: "serviceimg2",
            isVerified: false,
            isFeatured: true
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Available Services")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)
                
                ForEach(services) { service in
                    ServicesCardView(service: service)
                }
            }
            .padding(.horizontal)
        }
    }
}


struct ServicesCardView: View {
    let service: ServiceCard
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            Image(service.imageUrl)
                .resizable()
            //  .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
                .cornerRadius(12)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.5), Color.clear]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            
            
            VStack(alignment: .leading, spacing: 8) {
                
                HStack(spacing: 8) {
                    if service.isVerified {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.white)
                            Text("Verified")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.7))
                        .cornerRadius(12)
                    }
                    
                    if service.isFeatured {
                        Text("Featured")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 12)
                
                Spacer()
                
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Contact: \(service.contactNumber)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
                
                
                Button(action: {
                    
                    callPhoneNumber(service.contactNumber)
                }) {
                    Text("View")
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .frame(width: 80)
                        .padding(.vertical, 8)
                        .background(Color.yellow)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .frame(maxWidth: .infinity)
        .shadow(radius: 5)
    }
    
    
    private func callPhoneNumber(_ number: String) {
        let cleanNumber = number.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(cleanNumber)") {
            UIApplication.shared.open(url)
        }
    }
}

class LocationViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var isLoading = false
    let campground: CampgroundDetail
    
    init(campground: CampgroundDetail) {
        self.campground = campground
        self.region = MKCoordinateRegion(
            center: campground.base.coordinates,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    func getDirections() {
        let placemark = MKPlacemark(coordinate: campground.base.coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = campground.base.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}


struct LocationTab: View {
    let campground: CampgroundDetail
    @StateObject private var viewModel: LocationViewModel
    
    init(campground: CampgroundDetail) {
        self.campground = campground
        self._viewModel = StateObject(wrappedValue: LocationViewModel(campground: campground))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Map(coordinateRegion: $viewModel.region, annotationItems: [campground.base]) { item in
                MapAnnotation(coordinate: item.coordinates) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                        
                        Text(item.name)
                            .font(.caption)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(4)
                            .shadow(radius: 2)
                    }
                }
            }
            .frame(height: 300)
            .cornerRadius(12)
            
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Location Details")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(campground.base.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                
                HStack {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.green)
                    Text("Lat: \(String(format: "%.4f", campground.base.coordinates.latitude))")
                    Text("Long: \(String(format: "%.4f", campground.base.coordinates.longitude))")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                
                Button(action: {
                    viewModel.getDirections()
                }) {
                    HStack {
                        Image(systemName: "map.fill")
                        Text("Get Directions")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .padding()
    }
}


struct RatingAnalytics {
    var fiveStarCount: Int = 0
    var fourStarCount: Int = 0
    var threeStarCount: Int = 0
    var twoStarCount: Int = 0
    var oneStarCount: Int = 0
    
    var totalReviews: Int {
        fiveStarCount + fourStarCount + threeStarCount + twoStarCount + oneStarCount
    }
    
    
    func getCount(for rating: Int) -> Int {
        switch rating {
        case 5: return fiveStarCount
        case 4: return fourStarCount
        case 3: return threeStarCount
        case 2: return twoStarCount
        case 1: return oneStarCount
        default: return 0
        }
    }
}


class ReviewsViewModel: ObservableObject {
    @Published var reviews: [Review] = []
    @Published var ratingAnalytics = RatingAnalytics()
    
    func loadReviews(for campgroundId: String) {
        
        
        let sampleReviews = [
            Review(rating: 5.0, date: Date(timeIntervalSinceNow: -86400 * 2),
                   comment: "A peaceful and scenic spot! Amazing experience.",
                   authorName: "Carter Botosh"),
            Review(rating: 4.0, date: Date(timeIntervalSinceNow: -86400 * 3),
                   comment: "Great campsite, very well maintained.",
                   authorName: "Jaxson Septimus"),
            Review(rating: 3.0, date: Date(timeIntervalSinceNow: -86400 * 4),
                   comment: "Decent place, but could use better facilities.",
                   authorName: "Carla Press"),
            Review(rating: 5.0, date: Date(timeIntervalSinceNow: -86400 * 5),
                   comment: "Best camping experience ever!",
                   authorName: "John Doe")
        ]
        
        self.reviews = sampleReviews
        calculateRatingAnalytics()
    }
    
    private func calculateRatingAnalytics() {
        var analytics = RatingAnalytics()
        
        for review in reviews {
            let rating = Int(review.rating.rounded())
            switch rating {
            case 5: analytics.fiveStarCount += 1
            case 4: analytics.fourStarCount += 1
            case 3: analytics.threeStarCount += 1
            case 2: analytics.twoStarCount += 1
            case 1: analytics.oneStarCount += 1
            default: break
            }
        }
        
        self.ratingAnalytics = analytics
    }
}


struct ReviewsTab: View {
    let campground: CampgroundDetail
    @StateObject private var viewModel = ReviewsViewModel()
    @State private var showFullReviews = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Reviews")
                    .font(.headline)
                Spacer()
                Button("See All") {
                    showFullReviews = true
                }
                .foregroundColor(.blue)
            }
            
            
            HStack(alignment: .top, spacing: 32) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "%.1f", campground.base.rating))
                        .font(.system(size: 40, weight: .bold))
                    StarRatingView(rating: campground.base.rating)
                        .padding(.vertical, 2)
                    Text("Based on \(viewModel.ratingAnalytics.totalReviews) reviews")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    ForEach((1...5).reversed(), id: \.self) { rating in
                        RatingBarView(
                            rating: rating,
                            count: viewModel.ratingAnalytics.getCount(for: rating),
                            totalCount: viewModel.ratingAnalytics.totalReviews
                        )
                    }
                }
            }
            
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.reviews.prefix(2)) { review in
                    ReviewCellView(review: review)
                    Divider()
                }
            }
        }
        .sheet(isPresented: $showFullReviews) {
            ReviewsScreen()
        }
        .onAppear {
            viewModel.loadReviews(for: campground.base.id)
        }
    }
}


struct ReviewsiScreen: View {
    let campgroundId: String
    @StateObject private var viewModel = ReviewsViewModel()
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("Back")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(.blue)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Reviews")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.horizontal)
                    
                    
                    HStack(alignment: .top, spacing: 32) {
                        VStack(alignment: .leading, spacing: 4) {
                            let averageRating = viewModel.reviews.isEmpty ? 0 :
                            viewModel.reviews.reduce(0) { $0 + $1.rating } / Double(viewModel.reviews.count)
                            Text(String(format: "%.1f", averageRating))
                                .font(.system(size: 40, weight: .bold))
                            StarRatingView(rating: averageRating)
                                .padding(.vertical, 2)
                            Text("Based on \(viewModel.ratingAnalytics.totalReviews) reviews")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach((1...5).reversed(), id: \.self) { rating in
                                RatingBarView(
                                    rating: rating,
                                    count: viewModel.ratingAnalytics.getCount(for: rating),
                                    totalCount: viewModel.ratingAnalytics.totalReviews
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.reviews) { review in
                            ReviewCellView(review: review)
                                .padding(.horizontal)
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadReviews(for: campgroundId)
        }
    }
}
struct WeatherTab: View {
    let campground: CampgroundDetail
    @StateObject private var viewModel = WeatherViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else {
                    
                    if let current = viewModel.currentWeather {
                        currentWeatherView(weather: current)
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Hourly Forecast")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.hourlyForecast) { weather in
                                    hourlyForecastCard(weather: weather)
                                }
                            }
                        }
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("3-Day Forecast")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        VStack(spacing: 12) {
                            ForEach(viewModel.dailyForecast) { weather in
                                dailyForecastRow(weather: weather)
                                if weather.id != viewModel.dailyForecast.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.loadMockWeather()
        }
    }
    
    private func currentWeatherView(weather: WeatherInfo) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Weather")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(Int(weather.temperature))°C")
                        .font(.system(size: 48, weight: .bold))
                }
                
                Spacer()
                
                Image(systemName: weather.condition.rawValue)
                    .font(.system(size: 48))
                    .foregroundColor(.yellow)
            }
            
            HStack(spacing: 24) {
                WeatherDetailItem(icon: "drop.fill", value: "\(weather.humidity)%", label: "Humidity")
                WeatherDetailItem(icon: "wind", value: "\(Int(weather.windSpeed)) km/h", label: "Wind")
                WeatherDetailItem(icon: "umbrella.fill", value: "\(weather.precipitation)%", label: "Rain")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func hourlyForecastCard(weather: WeatherInfo) -> some View {
        VStack(spacing: 8) {
            Text(hourFormatter.string(from: weather.date))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Image(systemName: weather.condition.rawValue)
                .font(.title2)
                .foregroundColor(.yellow)
            
            Text("\(Int(weather.temperature))°")
                .font(.title3)
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
    
    private func dailyForecastRow(weather: WeatherInfo) -> some View {
        HStack {
            Text(dayFormatter.string(from: weather.date))
                .frame(width: 100, alignment: .leading)
            
            Image(systemName: weather.condition.rawValue)
                .foregroundColor(.yellow)
            
            Spacer()
            
            Text("\(Int(weather.temperature))°")
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
}

struct WeatherDetailItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}


private let hourFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter
}()

private let dayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    return formatter
}()

struct CampgroundDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CampgroundDetailView(campgroundId: "preview_id")
        }
    }
}
