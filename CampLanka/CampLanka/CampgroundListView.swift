//
//  CampgroundListView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-03.
//

import SwiftUI

// MARK: - Models
struct Campground: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let imageUrl: String
    let likes: Int
    let rating: Double
    var isFavorite: Bool = false
}

// MARK: - View Models
class CampgroundViewModel: ObservableObject {
    @Published var campgrounds: [Campground] = [
        Campground(name: "Wild Glamping Gal Oya", location: "Campgrounds in Ampara", imageUrl: "glamping", likes: 25, rating: 5.0),
        Campground(name: "Ella Retreat", location: "Campground in Ella", imageUrl: "ella-retreat", likes: 25, rating: 5.0),
        Campground(name: "Wangedigala Camp Site", location: "Campground in Ella", imageUrl: "wangedigala", likes: 25, rating: 5.0)
    ]
    
    func toggleFavorite(for campground: Campground) {
        if let index = campgrounds.firstIndex(where: { $0.id == campground.id }) {
            campgrounds[index].isFavorite.toggle()
        }
    }
}

// MARK: - Views
struct CampgroundListView: View {
    @StateObject private var viewModel = CampgroundViewModel()
    
    var body: some View {
        NavigationView {
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
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton()
                }
                
            }
            
        }

    }
}

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
                    //.frame(height: 200)
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

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .foregroundColor(.blue)
        }
    }
}

// MARK: - Preview
struct CampgroundListView_Previews: PreviewProvider {
    static var previews: some View {
        CampgroundListView()
    }
}
