//
//  CampgroundList.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-19.
//
import SwiftUI

struct CampgroundList: View {
    let title: String
    let campgrounds: [CampgroundBox]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(title)
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                LazyVStack(spacing: 16) {
                    ForEach(campgrounds) { campground in
                        NavigationLink(destination: CampgroundDetailView(campgroundId: campground.id)) {
                            CampgroundListCard(campground: campground)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CampgroundListCard: View {
    let campground: CampgroundBox
    
    var body: some View {
        HStack(spacing: 12) {
            
            AsyncImage(url: URL(string: campground.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(width: 120, height: 120)
            .cornerRadius(12)
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                Text(campground.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(campground.location)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.gray)
                    Text("\(campground.likes)")
                    
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", campground.rating))
                    
                    if let price = campground.startPrice {
                        Spacer()
                        Text("$\(Int(price))")
                            .bold()
                            .foregroundColor(.green)
                    }
                }
                .font(.subheadline)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
