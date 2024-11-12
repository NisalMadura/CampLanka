//
//  CampgroundDetailView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-12.
//

import SwiftUI
import FirebaseFirestore

// First, update the models to work with Firestore data
struct CampgroundBase: Identifiable {
    let id: String
    let name: String
    let location: String
    let imageUrl: String
    let likes: Int
    let rating: Double
    var isFavorite: Bool
    
    init?(id: String, data: [String: Any]) {
        self.id = id
        guard let name = data["name"] as? String,
              let location = data["location"] as? String,
              let imageUrl = data["imageUrl"] as? String,
              let likes = data["likes"] as? Int,
              let rating = data["rating"] as? Double else {
            return nil
        }
        self.name = name
        self.location = location
        self.imageUrl = imageUrl
        self.likes = likes
        self.rating = rating
        self.isFavorite = data["isFavorite"] as? Bool ?? false
    }
}
// MARK: - Reservation Info
struct ReservationInfo {
    let isReservationRequired: Bool
    let policy: String
    let maxStayDays: Int
}

// MARK: - Contact Info
struct ContactInfo {
    let office: String
    let phone: String
    let emergency: String
    let email: String
}

// MARK: - Access Method
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

// MARK: - Connectivity Option
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

// MARK: - Site Type
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

// MARK: - Feature
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
    let base: CampgroundBase
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
        // Initialize base data
        guard let base = CampgroundBase(id: id, data: baseData) else {
            return nil
        }
        self.base = base
        
        // Initialize detail data
        self.numberOfReviews = detailData["numberOfReviews"] as? Int ?? 0
        self.servicesCount = detailData["servicesCount"] as? Int ?? 0
        self.distanceInMeters = detailData["distanceInMeters"] as? Int ?? 0
        self.description = detailData["description"] as? String ?? ""
        
        // Initialize reservation info
        if let reservationData = detailData["reservationInfo"] as? [String: Any] {
            self.reservationInfo = ReservationInfo(
                isReservationRequired: reservationData["isReservationRequired"] as? Bool ?? false,
                policy: reservationData["policy"] as? String ?? "",
                maxStayDays: reservationData["maxStayDays"] as? Int ?? 0
            )
        } else {
            self.reservationInfo = ReservationInfo(isReservationRequired: false, policy: "", maxStayDays: 0)
        }
        
        // Initialize contact info
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
        
        // Initialize access methods
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
        
        // Initialize connectivity
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
        
        // Initialize site types and features as before
        self.siteTypes = [SiteType(type: .tent)]
        self.features = [
            Feature(type: .firewood),
            Feature(type: .drinkingWater),
            Feature(type: .parking)
        ]
    }
}

// Create a ViewModel to handle Firebase operations
class CampgroundDetailViewModel: ObservableObject {
    private let db = Firestore.firestore()
    @Published var campgroundDetail: CampgroundDetail?
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    func fetchCampgroundDetail(id: String) {
        isLoading = true
        errorMessage = nil
        
        // First, fetch the base campground data
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
            
            // Then fetch the detailed data
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
                    
                    // Create the CampgroundDetail object
                    if let campgroundDetail = CampgroundDetail(id: id, baseData: baseData, detailData: detailData) {
                        self?.campgroundDetail = campgroundDetail
                    }
                    
                    self?.isLoading = false
                }
            }
        }
    }
    
    func toggleFavorite() {
        guard let detail = campgroundDetail else { return }
        
        let newValue = !detail.base.isFavorite
        db.collection("campgrounds").document(detail.base.id).updateData([
            "isFavorite": newValue
        ])
    }
}

// Update the main CampgroundDetailView
struct CampgroundDetailView: View {
    @StateObject private var viewModel = CampgroundDetailViewModel()
    @State private var selectedTab = 0
    let campgroundId: String
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if let campground = viewModel.campgroundDetail {
                VStack(alignment: .leading, spacing: 0) {
                    // Header Image
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
                    
                    // Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(campground.base.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.toggleFavorite()
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
                    
                    // Tab Bar
                    tabBar(campground: campground)
                    
                    // Content
                    tabContent(campground: campground)
                        .padding(.horizontal)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            /*ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }*/
        }
        .onAppear {
            viewModel.fetchCampgroundDetail(id: campgroundId)
        }
    }
    
    // Keep your existing tab bar and content methods
    private func tabBar(campground: CampgroundDetail) -> some View {
        HStack(spacing: 0) {
            TabButton(title: "Overview", count: nil, isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabButton(title: "Services", count: campground.servicesCount, isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            TabButton(title: "Location", count: campground.distanceInMeters, isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            
            TabButton(title: "Reviews", count: campground.numberOfReviews, isSelected: selectedTab == 3) {
                selectedTab = 3
            }
        }
        .padding(.horizontal)
    }
    
    private func tabContent(campground: CampgroundDetail) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            switch selectedTab {
            case 0:
                OverviewTab(campground: campground)
            case 1:
                ServicesTab(campground: campground)
            case 2:
                LocationTab()
            case 3:
                ReviewsTab()
            default:
                EmptyView()
            }
        }
        .padding(.top)
    }
}
// MARK: - Supporting Views
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

// MARK: - Tab Content Views
struct OverviewTab: View {
    let campground: CampgroundDetail
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // About Section
            SectionView(title: "About") {
                Text(campground.description)
                    .lineSpacing(4)
            }
            
            // Reservation Info Section
            SectionView(title: "Reservation Info") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reservation Required: \(campground.reservationInfo.isReservationRequired ? "Yes" : "No")")
                    Text(campground.reservationInfo.policy)
                    Text("Maximum Stay: \(campground.reservationInfo.maxStayDays) days")
                }
            }
            
            // Contact Information
            SectionView(title: "Contact Information") {
                VStack(alignment: .leading, spacing: 12) {
                    CampgroundContactRow(title: "Park Office", value: campground.contactInfo.office)
                    CampgroundContactRow(title: "Phone", value: campground.contactInfo.phone)
                    CampgroundContactRow(title: "Emergency Contact", value: campground.contactInfo.emergency)
                    CampgroundContactRow(title: "Email", value: campground.contactInfo.email)
                }
            }
            
            // Access Methods
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
            
            // Connectivity
            SectionView(title: "Stay Connected") {
                HStack(spacing: 24) {
                    ForEach(campground.connectivity) { option in
                        connectivityView(for: option)
                    }
                }
            }
            
            // Site Types
            SectionView(title: "Site Types") {
                HStack(spacing: 24) {
                    ForEach(campground.siteTypes) { siteType in
                        siteTypeView(for: siteType)
                    }
                }
            }
            
            // Features
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

struct ServicesTab: View {
    let campground: CampgroundDetail
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Available Services")
                .font(.headline)
            
            // Add your services content here
            Text("Services content coming soon...")
                .foregroundColor(.gray)
        }
    }
}

struct LocationTab: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Location Information")
                .font(.headline)
            
            // Add your location content here
            Text("Location content coming soon...")
                .foregroundColor(.gray)
        }
    }
}

struct ReviewsTab: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Reviews")
                .font(.headline)
            
            // Add your reviews content here
            Text("Reviews content coming soon...")
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Preview Provider
struct CampgroundDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CampgroundDetailView(campgroundId: "preview_id")
        }
    }
}
