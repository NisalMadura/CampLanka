//
//  HomeView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-05.
//



import SwiftUI
import FirebaseFirestore

struct CampgroundBox: Identifiable {
    let id: String
    let name: String
    let location: String
    let rating: Double
    let likes: Int
    let image: String
    var isFavorite: Bool
    var startPrice: Double?
    
    init(id: String, name: String, location: String, rating: Double, likes: Int, image: String, isFavorite: Bool, startPrice: Double?) {
        self.id = id
        self.name = name
        self.location = location
        self.rating = rating
        self.likes = likes
        self.image = image
        self.isFavorite = isFavorite
        self.startPrice = startPrice
    }
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.name = data["name"] as? String ?? ""
        self.location = data["location"] as? String ?? ""
        self.rating = data["rating"] as? Double ?? 0.0
        self.likes = data["likes"] as? Int ?? 0
        self.image = data["imageUrl"] as? String ?? ""
        self.isFavorite = data["isFavorite"] as? Bool ?? false
        self.startPrice = data["startPrice"] as? Double
    }
}

class HomeViewModel: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var publicCampgrounds: [CampgroundBox] = []
    @Published var bookableCampgrounds: [CampgroundBox] = []
    @Published var popularCampgrounds: [CampgroundBox] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func fetchCampgrounds() {
        isLoading = true
        
        // Fetch Public Campgrounds
        db.collection("campgrounds")
            .whereField("type", isEqualTo: "public")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching public campgrounds: \(error)")
                    return
                }
                
                self?.publicCampgrounds = snapshot?.documents.map { doc in
                    CampgroundBox(id: doc.documentID, data: doc.data())
                } ?? []
            }
        
        // Fetch Bookable Campgrounds
        APIManager.shared.fetchGlampingSriLanka { [weak self] hotels, error in
            self?.isLoading = false
            
            if let error = error {
                print("Error fetching bookable campgrounds: \(error)")
                self?.errorMessage = error.localizedDescription
                return
            }
            
            if let hotels = hotels {
                print("Received \(hotels.count) hotels from API")
                
                self?.bookableCampgrounds = hotels.map { hotel in
                    print("Processing hotel: \(hotel.name)")
                    return CampgroundBox(
                        id: UUID().uuidString,
                        name: hotel.name,
                        location: hotel.address,
                        rating: Double(hotel.starRating),
                        likes: 0,
                        image: hotel.images.first ?? "",
                        isFavorite: false,
                        startPrice: hotel.price
                    )
                }
                
                if self?.bookableCampgrounds.isEmpty == true {
                    print("No bookable campgrounds found after processing")
                    self?.errorMessage = "No glamping locations found"
                } else {
                    print("Successfully loaded \(self?.bookableCampgrounds.count ?? 0) bookable campgrounds")
                }
            } else {
                print("No hotels data received from API")
                self?.errorMessage = "No data received from booking service"
            }
        }
        
        // Fetch Popular Campgrounds
        db.collection("campgrounds")
            .whereField("type", isEqualTo: "popular")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching popular campgrounds: \(error)")
                    return
                }
                
                self?.popularCampgrounds = snapshot?.documents.map { doc in
                    CampgroundBox(id: doc.documentID, data: doc.data())
                } ?? []
            }
    }
}

struct ProfileButton: View {
    let destination: ProfileView
    
    var body: some View {
        NavigationLink(destination: destination) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.black)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct HomeViewscn: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Good Morning!")
                        .font(.title)
                        .bold()
                        .padding(.top, -50)
                    
                    CampgroundSection(
                        title: "Public Campgrounds",
                        campgrounds: viewModel.publicCampgrounds,
                        viewAll: {}
                    )
                    
                    BookableCampgroundSection(
                        title: "Bookable Campgrounds",
                        campgrounds: viewModel.bookableCampgrounds,
                        viewAll: {}
                    )
                    
                    PopularCampgroundSection(
                        title: "CAMPLANKA SPECIAL",
                        subtitle: "Most Popular",
                        campgrounds: viewModel.popularCampgrounds,
                        viewAll: {}
                    )
                    
                    TripPlanningBanner()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "bell")
                                .foregroundColor(.black)
                        }
                        ProfileButton(destination: ProfileView())
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            viewModel.fetchCampgrounds()
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct CampgroundSection: View {
    let title: String
    let campgrounds: [CampgroundBox]
    let viewAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button("View all", action: viewAll)
                    .foregroundColor(.green)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(campgrounds) { campground in
                        NavigationLink(destination: CampgroundDetailView(campgroundId: campground.id)) {
                            CampgroundCard(campground: campground)
                        }
                    }
                }
            }
        }
    }
}

struct CampgroundCard: View {
    let campground: CampgroundBox
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: campground.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(width: 300, height: 200)
            .cornerRadius(12)
            
            Text(campground.name)
                .font(.headline)
            
            Text(campground.location)
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.gray)
                Text("\(campground.likes)")
                
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", campground.rating))
            }
        }
        .frame(width: 300)
    }
}

struct BookableCampgroundSection: View {
    let title: String
    let campgrounds: [CampgroundBox]
    let viewAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button("View all", action: viewAll)
                    .foregroundColor(.green)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(campgrounds) { campground in
                        NavigationLink(destination: CampgroundDetailView(campgroundId: campground.id)) {
                            BookableCampgroundCard(campground: campground)
                        }
                    }
                }
            }
        }
    }
}

struct BookableCampgroundCard: View {
    let campground: CampgroundBox
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: campground.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(width: 300, height: 200)
            .cornerRadius(12)
            
            Text(campground.name)
                .font(.headline)
            
            Text(campground.location)
                .foregroundColor(.gray)
            
            HStack {
                if let price = campground.startPrice {
                    Text("Start from")
                        .foregroundColor(.gray)
                    Text("$ \(Int(price))/pax")
                        .bold()
                }
                
                Spacer()
                
                Button("Book") {
                   
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .frame(width: 300)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct PopularCampgroundSection: View {
    let title: String
    let subtitle: String
    let campgrounds: [CampgroundBox]
    let viewAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .foregroundColor(.green)
            
            HStack {
                Text(subtitle)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button("View all", action: viewAll)
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 15) {
                ForEach(campgrounds) { campground in
                    NavigationLink(destination: CampgroundDetailView(campgroundId: campground.id)) {
                        PopularCampgroundCard(campground: campground)
                    }
                }
            }
        }
    }
}

struct PopularCampgroundCard: View {
    let campground: CampgroundBox
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: campground.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(width: 300, height: 150)
            .cornerRadius(12)
            
            Text(campground.name)
                .font(.headline)
            
            Text(campground.location)
                .foregroundColor(.gray)
            
   
        }
        .frame(width: 300)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct TripPlanningBanner: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.green.opacity(0.8), .green.opacity(0.4)]),
                startPoint: .leading,
                endPoint: .trailing
            )
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Camping trip planning made easy")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Add recommended campsites,\ninstantly create packing lists,\nschedule your trips,\nand get adventure reminders.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                    
                    NavigationLink(destination: TripPlannerView()) {
                        Text("Start Planning")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                Image("tent-illustration")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
            }
            .padding()
        }
        .cornerRadius(12)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewscn()
    }
}
    

