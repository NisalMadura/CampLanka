import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth


class WishListViewModel: ObservableObject {
    @Published var savedCampgrounds: [Campground] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    private let db = Firestore.firestore()
    
    init() {
        fetchUserWishlist()
        
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if user != nil {
                self?.fetchUserWishlist()
            } else {
                self?.savedCampgrounds.removeAll()
            }
        }
    }
    
    func fetchUserWishlist() {
        guard let userId = Auth.auth().currentUser?.uid else {
            savedCampgrounds.removeAll()
            return
        }
        
        isLoading = true
        
        db.collection("users")
            .document(userId)
            .collection("wishlist")
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = "Error loading wishlist: \(error.localizedDescription)"
                        self?.showError = true
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        self?.savedCampgrounds = []
                        return
                    }
                    
                    self?.savedCampgrounds = documents.compactMap { document -> Campground? in
                        try? document.data(as: Campground.self)
                    }
                }
            }
    }
    
    func removeFromWishlist(_ campground: Campground) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users")
            .document(userId)
            .collection("wishlist")
            .document(campground.id)
            .delete() { [weak self] error in
                if let error = error {
                    self?.errorMessage = "Error removing from wishlist: \(error.localizedDescription)"
                    self?.showError = true
                }
            }
    }
}

struct SavedCampgroundCell: View {
    let campground: Campground
    let onRemove: () -> Void
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            ZStack(alignment: .topTrailing) {
                Image(campground.imageUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .cornerRadius(8)
                
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Image(systemName: "heart.fill")
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
        .alert("Remove from Wishlist", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                onRemove()
            }
        } message: {
            Text("Are you sure you want to remove this campground from your wishlist?")
        }
        
    }
}


struct WishListView: View {
    @StateObject private var viewModel = WishListViewModel()
    @State private var showLoginView = false
    
    var body: some View {
        NavigationView {
            Group {
                if Auth.auth().currentUser == nil {
                
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("Sign in to View Your Wishlist")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Save your favorite campgrounds and access them anywhere")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            showLoginView = true
                        }) {
                            Text("Sign In")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 200)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView()
                        } else if viewModel.savedCampgrounds.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "heart")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                
                                Text("No Saved Campgrounds")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("Start exploring and save your favorite campgrounds")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(viewModel.savedCampgrounds) { campground in
                                        SavedCampgroundCell(campground: campground) {
                                            viewModel.removeFromWishlist(campground)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.vertical)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Wishlist")
            .sheet(isPresented: $showLoginView) {
                SignInView()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
}


struct WishListView_Previews: PreviewProvider {
    static var previews: some View {
        WishListView()
    }
}
