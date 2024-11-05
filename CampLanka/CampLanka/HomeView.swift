//
//  HomeView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-05.
//

import SwiftUI

struct ProfileButton: View {
    var body: some View {
        Button(action: { }) {
            Image(systemName: "person.circle")
                .foregroundColor(.black)
                .font(.system(size: 24))
        }
    }
}
// MARK: - Models
struct CampgroundBox: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let rating: Double
    let likes: Int
    let image: String
    var isFavorite: Bool = false
    var startPrice: Double?
}

// MARK: - Views
struct HomeViewscn: View {
    @State private var searchText = ""
    
    let publicCampgrounds: [CampgroundBox] = [
        CampgroundBox(name: "Madulsima Camping", location: "Madulsima", rating: 5.0, likes: 25, image: "homepic1"),
        CampgroundBox(name: "Camping at Unawatuna", location: "Unawatuna", rating: 5.0, likes: 25, image: "homepic2"),
        CampgroundBox(name: "Blue Elephant opens", location: "NuwaraEliya", rating: 5.0, likes: 25, image: "homepic3")
    ]
    
    let bookableCampgrounds: [CampgroundBox] = [
        CampgroundBox(name: "Glamping By Offtrek", location: "Kandy", rating: 4.8, likes: 0, image: "glamping", startPrice: 200),
        CampgroundBox(name: "Glamping By Offtrek", location: "Kandy", rating: 4.8, likes: 0, image: "homepic4", startPrice: 200)
        // Add more bookable campgrounds
    ]
    
    let popularCampgrounds: [CampgroundBox] = [
        CampgroundBox(name: "Mandaram Nuwara Camping", location: "Pidurutalagala", rating: 5.0, likes: 25, image: "homepic5"),
        CampgroundBox(name: "Mahoora Tented Safari Camps", location: "Habarana", rating: 5.0, likes: 25, image: "homepic6"),
        CampgroundBox(name: "Narangala Mountain Camping", location: "Badulla", rating: 5.0, likes: 25, image: "glamping"),
        CampgroundBox(name: "Camping Horton plains", location: "Ohiya", rating: 5.0, likes: 25, image: "homepic8")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Good Morning!")
                        .font(.title)
                        .bold()
                        .padding(.top)
                    
                    // Search Bar
                    SearchBar(text: $searchText)
                    
                    // Public Campgrounds Section
                    CampgroundSection(
                        title: "Public Campgrounds",
                        campgrounds: publicCampgrounds
                    )
                    
                    // Bookable Campgrounds Section
                    BookableCampgroundSection(
                        title: "Bookable Campgrounds",
                        campgrounds: bookableCampgrounds
                    )
                    
                    // Most Popular Section
                    PopularCampgroundSection(
                        title: "CAMPLANKA SPECIAL",
                        subtitle: "Most Popular",
                        campgrounds: popularCampgrounds
                    )
                    
                    // Trip Planning Banner
                    TripPlanningBanner()
                    
                }
                .padding()
            
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: { }) {
                            Image(systemName: "bell")
                                .foregroundColor(.black)
                        }
                        
                        ProfileButton()
                    }
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Near Me", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct CampgroundSection: View {
    let title: String
    let campgrounds: [CampgroundBox]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button("View all") {
                    // Handle view all action
                }
                .foregroundColor(.green)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(campgrounds) { campground in
                        CampgroundCard(campground: campground)
                    }
                }
            }
        }
    }
}

struct BookableCampgroundSection: View {
    let title: String
    let campgrounds: [CampgroundBox]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button("View all") {
                    // Handle view all action
                }
                .foregroundColor(.green)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(campgrounds) { campground in
                        BookableCampgroundCard(campground: campground)
                    }
                }
            }
        }
    }
}

struct PopularCampgroundSection: View {
    let title: String
    let subtitle: String
    let campgrounds: [CampgroundBox]
    
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
                
                Button("View all") {
                    // Handle view all action
                }
                .foregroundColor(.green)
            }
            
            VStack(spacing: 15) {
                ForEach(campgrounds) { campground in
                    PopularCampgroundCard(campground: campground)
                }
            }
        }
    }
}

struct CampgroundCard: View {
    let campground: CampgroundBox
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(campground.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
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

struct BookableCampgroundCard: View {
    let campground: CampgroundBox
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(campground.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
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
                    // Handle booking action
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

struct PopularCampgroundCard: View {
    let campground: CampgroundBox
    
    var body: some View {
        HStack {
            Image(campground.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 80)
                .cornerRadius(12)
            
            VStack(alignment: .leading) {
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
            
            Spacer()
            
            Button(action: { }) {
                Image(systemName: "heart")
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Circle().stroke(Color.gray.opacity(0.3)))
            }
        }
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
                    
                    Button("Start Planning") {
                        // Handle start planning action
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Image("tent-illustration") // Add this image to your assets
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
            }
            .padding()
        }
        .cornerRadius(12)
        
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewscn()
    }
}
