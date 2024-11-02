//
//  WishListView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-02.
//

import SwiftUI

// Data Model for Camping Location
struct CampingLocation: Identifiable, Codable {
    let id: UUID
    let name: String
    let location: String
    let imageURL: String
    let likes: Int
    let rating: Double
    var isWishlisted: Bool
    
    init(id: UUID = UUID(), name: String, location: String, imageURL: String,
         likes: Int = 0, rating: Double = 0.0, isWishlisted: Bool = false) {
        self.id = id
        self.name = name
        self.location = location
        self.imageURL = imageURL
        self.likes = likes
        self.rating = rating
        self.isWishlisted = isWishlisted
    }
}

// Wish List View Model
class WishListViewModel: ObservableObject {
    @Published var wishlistedLocations: [CampingLocation] = []
    private let userDefaults = UserDefaults.standard
    private let wishlistKey = "wishlisted_locations"
    
    init() {
        loadWishlistedLocations()
    }
    
    func loadWishlistedLocations() {
        if let data = userDefaults.data(forKey: wishlistKey),
           let locations = try? JSONDecoder().decode([CampingLocation].self, from: data) {
            wishlistedLocations = locations
        }
    }
    
    func saveWishlistedLocations() {
        if let encoded = try? JSONEncoder().encode(wishlistedLocations) {
            userDefaults.set(encoded, forKey: wishlistKey)
        }
    }
    
    func addToWishlist(_ location: CampingLocation) {
        var updatedLocation = location
        updatedLocation.isWishlisted = true
        wishlistedLocations.append(updatedLocation)
        saveWishlistedLocations()
    }
    
    func removeFromWishlist(_ location: CampingLocation) {
        wishlistedLocations.removeAll { $0.id == location.id }
        saveWishlistedLocations()
    }
}

// Main Wish List View
struct WishListView: View {
    @StateObject private var viewModel = WishListViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.wishlistedLocations) { location in
                        WishListItemCard(location: location) { action in
                            switch action {
                            case .addToPlan:
                                // Handle add to plan action
                                break
                            case .remove:
                                viewModel.removeFromWishlist(location)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarItems(leading: backButton)
            .navigationTitle("Wish List")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                Text("Back")
                    .foregroundColor(.blue)
            }
        }
    }
}

// Wish List Item Card
struct WishListItemCard: View {
    let location: CampingLocation
    let onAction: (CardAction) -> Void
    
    enum CardAction {
        case addToPlan
        case remove
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image
            AsyncImage(url: URL(string: location.imageURL)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .cornerRadius(12)
            .overlay(
                Button(action: {
                    onAction(.addToPlan)
                }) {
                    Text("Add To Plan")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(12),
                alignment: .topTrailing
            )
            
            // Location Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(location.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.gray)
                        Text("\(location.likes)")
                            .foregroundColor(.gray)
                        Text("★ \(String(format: "%.1f", location.rating))")
                            .foregroundColor(.gray)
                    }
                }
                
                Text(location.location)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Preview Provider
struct WishListView_Previews: PreviewProvider {
    static var previews: some View {
        WishListView()
    }
}

// Extension to add wishlist functionality to camping locations view
/*extension CampingLocationView {
    func toggleWishlist(_ location: CampingLocation) {
        let wishListVM = WishListViewModel()
        if location.isWishlisted {
            wishListVM.removeFromWishlist(location)
        } else {
            wishListVM.addToWishlist(location)
        }
    }
}*/
