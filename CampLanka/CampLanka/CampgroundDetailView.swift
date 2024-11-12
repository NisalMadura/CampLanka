//
//  CampgroundDetailView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-12.
//

// MARK: - Models/CampgroundModels.swift
import SwiftUI

// Base model for list views
struct CampgroundBase: Identifiable, Codable {
    let id: String
    let name: String
    let location: String
    let imageUrl: String
    let likes: Int
    let rating: Double
    var isFavorite: Bool
    
    init(id: String = UUID().uuidString,
         name: String,
         location: String,
         imageUrl: String,
         likes: Int,
         rating: Double,
         isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.location = location
        self.imageUrl = imageUrl
        self.likes = likes
        self.rating = rating
        self.isFavorite = isFavorite
    }
}

// Extended model for detail view
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
    
    var isFavorite: Bool {
        get { base.isFavorite }
        set { /* Implement if needed */ }
    }
    
    // Convenience accessors
    var name: String { base.name }
    var location: String { base.location }
    var rating: Double { base.rating }
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
    let id = UUID()
    let type: AccessType
    let description: String
    
    enum AccessType {
        case hikeIn
        case driveIn
        case walkIn
    }
}

struct ConnectivityOption: Identifiable {
    let id = UUID()
    let type: ConnectivityType
    let provider: String?
    
    enum ConnectivityType {
        case noWifi
        case cellular
    }
}

struct SiteType: Identifiable {
    let id = UUID()
    let type: CampSiteType
    
    enum CampSiteType {
        case tent
    }
}

struct Feature: Identifiable {
    let id = UUID()
    let type: FeatureType
    
    enum FeatureType {
        case firewood
        case drinkingWater
        case parking
    }
}

// MARK: - Views/CampgroundDetailView.swift
struct CampgroundDetailView: View {
    @State private var selectedTab = 0
    @State private var campground: CampgroundDetail
    
    init(campground: CampgroundDetail) {
        self._campground = State(initialValue: campground)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerImage
                titleSection
                tabBar
                
                // Main content
                tabContent
                    .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
    }
    
    private var headerImage: some View {
        AsyncImage(url: URL(string: campground.base.imageUrl)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Image("homepic3")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            @unknown default:
                EmptyView()
            }
        }
        .frame(height: 250)
        .clipped()
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(campground.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    // Toggle favorite
                }) {
                    Image(systemName: campground.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(campground.isFavorite ? .red : .gray)
                        .font(.title2)
                }
            }
            
            Text(campground.location)
                .foregroundColor(.gray)
            
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", campground.rating))
                Text("(\(campground.numberOfReviews) Reviews)")
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                // Add to plan functionality
            }) {
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
    }
    
    private var tabBar: some View {
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
    
    private var tabContent: some View {
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

// MARK: - Views/Tabs/OverviewTab.swift
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

// MARK: - Views/Components/SupportingViews.swift
struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.primary)
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

// MARK: - Views/Tabs/ServicesTab.swift
struct ServicesTab: View {
    let campground: CampgroundDetail
    
    var body: some View {
        Text("Services Content")
        // Implement services content
    }
}

// MARK: - Views/Tabs/LocationTab.swift
struct LocationTab: View {
    var body: some View {
        Text("Location Content")
        // Implement location content
    }
}

// MARK: - Views/Tabs/ReviewsTab.swift
struct ReviewsTab: View {
    var body: some View {
        Text("Reviews Content")
        // Implement reviews content
    }
}

// MARK: - Preview Provider
struct CampgroundDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CampgroundDetailView(campground: CampgroundDetail(
                base: CampgroundBase(
                    name: "Horton Plains Campground",
                    location: "Badulla Sri Lanka",
                    imageUrl: "https://example.com/horton_plains.jpg",
                    likes: 156,
                    rating: 4.6,
                    isFavorite: false
                ),
                numberOfReviews: 230,
                servicesCount: 12,
                distanceInMeters: 35,
                description: "A scenic and remote camping spot located within Horton Plains National Park, ideal for nature lovers, hikers, and wildlife enthusiasts. Enjoy beautiful sunrises, cool temperatures, and easy access to some of Sri Lanka's most famous hiking trails.",
                reservationInfo: ReservationInfo(
                    isReservationRequired: false,
                    policy: "First-come, first-served. Arrive early during weekends and holidays.",
                    maxStayDays: 5
                ),
                contactInfo: ContactInfo(
                    office: "Horton Plains National Park Office",
                    phone: "+94 112 233456",
                    emergency: "+94 777 987654 (Forest Department)",
                    email: "hortonplains@parks.lk"
                ),
                accessMethods: [
                    AccessMethod(type: .hikeIn, description: "Park in a lot, hike to your campsite"),
                    AccessMethod(type: .driveIn, description: "Park next to your campsite"),
                    AccessMethod(type: .walkIn, description: "Park in a lot, walk to your campsite")
                ],
                connectivity: [
                    ConnectivityOption(type: .noWifi, provider: nil),
                    ConnectivityOption(type: .cellular, provider: "T-Mobile")
                ],
                siteTypes: [
                    SiteType(type: .tent)
                ],
                features: [
                    Feature(type: .firewood),
                    Feature(type: .drinkingWater),
                    Feature(type: .parking)
                ]
            ))
        }
    }
}
