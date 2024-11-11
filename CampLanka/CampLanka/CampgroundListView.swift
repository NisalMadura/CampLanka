//
//  CampgroundListView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-03.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

// MARK: - Models
struct Campground: Identifiable, Codable {
    let id: String
    let name: String
    let location: String
    let imageUrl: String
    let likes: Int
    let rating: Double
    var isFavorite: Bool
    
    init(id: String = UUID().uuidString, name: String, location: String, imageUrl: String, likes: Int, rating: Double, isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.location = location
        self.imageUrl = imageUrl
        self.likes = likes
        self.rating = rating
        self.isFavorite = isFavorite
    }
}

// MARK: - View Models
class CampgroundViewModel: ObservableObject {
    @Published var campgrounds: [Campground] = [
        Campground(name: "Wild Glamping Gal Oya", location: "Campgrounds in Ampara", imageUrl: "glamping", likes: 25, rating: 5.0),
        Campground(name: "Ella Retreat", location: "Campground in Ella", imageUrl: "ella-retreat", likes: 25, rating: 5.0),
        Campground(name: "Wangedigala Camp Site", location: "Campground in Ella", imageUrl: "wangedigala", likes: 25, rating: 5.0)
    ]
    
    @Published var wishlist: [Campground] = []
    @Published var showLoginAlert = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    private let db = Firestore.firestore()
    
    init() {
        // Set up auth state listener
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if user != nil {
                self?.loadWishlist()
            } else {
                self?.wishlist.removeAll()
            }
        }
    }
    
    private func loadWishlist() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users")
            .document(userId)
            .collection("wishlist")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching wishlist: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.wishlist = documents.compactMap { document -> Campground? in
                    do {
                        return try document.data(as: Campground.self)
                    } catch {
                        print("Error decoding campground: \(error)")
                        return nil
                    }
                }
                
                // Update isFavorite status in campgrounds
                self?.updateCampgroundFavoriteStatus()
            }
    }
    
    private func updateCampgroundFavoriteStatus() {
        for (index, _) in campgrounds.enumerated() {
            campgrounds[index].isFavorite = wishlist.contains(where: { $0.id == campgrounds[index].id })
        }
    }
    
    func toggleFavorite(for campground: Campground) {
        guard let user = Auth.auth().currentUser else {
            showLoginAlert = true
            return
        }
        
        let wishlistRef = db.collection("users").document(user.uid).collection("wishlist")
        
        if let index = campgrounds.firstIndex(where: { $0.id == campground.id }) {
            // Toggle the favorite status locally
            campgrounds[index].isFavorite.toggle()
            
            if campgrounds[index].isFavorite {
                // Add to Firebase
                do {
                    try wishlistRef.document(campground.id).setData(from: campgrounds[index])
                } catch {
                    errorMessage = "Error saving to wishlist: \(error.localizedDescription)"
                    showError = true
                    // Revert the local change if saving fails
                    campgrounds[index].isFavorite.toggle()
                }
            } else {
                // Remove from Firebase
                wishlistRef.document(campground.id).delete() { [weak self] error in
                    if let error = error {
                        self?.errorMessage = "Error removing from wishlist: \(error.localizedDescription)"
                        self?.showError = true
                        // Revert the local change if deletion fails
                        DispatchQueue.main.async {
                            self?.campgrounds[index].isFavorite.toggle()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - CampgroundCell View
struct CampgroundCell: View {
    let campground: Campground
    let onFavoriteTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image
            ZStack(alignment: .topTrailing) {
                Image(campground.imageUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .cornerRadius(8)
                
                Button(action: onFavoriteTap) {
                    Image(systemName: campground.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(campground.isFavorite ? .red : .white)
                        .padding(8)
                        .background(Circle().fill(Color.black.opacity(0.3)))
                        .padding(8)
                }
            }
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(campground.name)
                    .font(.headline)
                
                Text(campground.location)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                        Text("\(campground.likes)")
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                        Text(String(format: "%.1f", campground.rating))
                    }
                }
                .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Wishlist View
struct WishlistView: View {
    @ObservedObject var viewModel: CampgroundViewModel
    @State private var showLoginAlert = false
    
    var body: some View {
        NavigationView {
            Group {
                if Auth.auth().currentUser != nil {
                    List {
                        ForEach(viewModel.wishlist) { campground in
                            CampgroundCell(campground: campground) {
                                viewModel.toggleFavorite(for: campground)
                            }
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        Text("Please log in to view your wishlist")
                            .font(.headline)
                        
                        NavigationLink(destination: SignInView()) {
                            Text("Log In")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .navigationTitle("Wishlist")
        }
    }
}

// MARK: - CampgroundListView
struct CampgroundListView: View {
    @StateObject private var viewModel = CampgroundViewModel()
    @State private var navigateToDetails = false
    @State private var showLogin = false
    
    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.campgrounds) { campground in
                    CampgroundCell(campground: campground) {
                        viewModel.toggleFavorite(for: campground)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Recommended for you")
                            .font(.system(size: 20, weight: .bold))
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: TripPlannerDetailsView(), isActive: $navigateToDetails) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Login Required", isPresented: $viewModel.showLoginAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Login") {
                showLogin = true
            }
        } message: {
            Text("Please log in to save campgrounds to your wishlist")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $showLogin) {
            SignInView()
        }
    }
}

// MARK: - Preview
struct CampgroundListView_Previews: PreviewProvider {
    static var previews: some View {
        CampgroundListView()
    }
}
