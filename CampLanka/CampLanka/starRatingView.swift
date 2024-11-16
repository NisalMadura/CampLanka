//
//  starRatingView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-05.
//

import SwiftUI

// MARK: - Models
struct Review: Identifiable {
    let id = UUID()
    let rating: Double
    let date: Date
    let comment: String
    let authorName: String
}

// MARK: - Review Cell View
struct ReviewCellView: View {
    let review: Review
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                StarRatingView(rating: review.rating)
                    .frame(height: 16)
                Text(String(format: "%.1f", review.rating))
                    .foregroundColor(.black)
                    .font(.system(size: 14))
                Text(dateFormatter.string(from: review.date))
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                Spacer()
                Button(action: {
                    // Handle more button action
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            
            Text(review.comment)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .lineSpacing(4)
            
            Text(review.authorName)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Star Rating View
struct StarRatingView: View {
    let rating: Double
    let maxRating = 5
    
    var body: some View {
        HStack(spacing: 1) {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(star <= Int(rating.rounded()) ? .yellow : .gray.opacity(0.3))
            }
        }
    }
}

// MARK: - Rating Bar View
struct RatingBarView: View {
    let rating: Int
    let count: Int
    let totalCount: Int
    
    var barWidth: CGFloat {
        let percentage = CGFloat(count) / CGFloat(totalCount)
        return percentage * 150 // Adjusted for better fit
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(rating)")
                .font(.system(size: 12))
                .frame(width: 8)
            Rectangle()
                .frame(width: barWidth, height: 4)
                .foregroundColor(.green)
            Spacer()
        }
        .frame(height: 20)
    }
}

// MARK: - Reviews Screen
struct ReviewsScreen: View {
    @State private var reviews: [Review] = []
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    
    var averageRating: Double {
        guard !reviews.isEmpty else { return 0 }
        return reviews.reduce(0) { $0 + $1.rating } / Double(reviews.count)
    }
    
    var ratingCounts: [Int: Int] {
        var counts: [Int: Int] = [:]
        reviews.forEach { review in
            let rating = Int(review.rating.rounded())
            counts[rating, default: 0] += 1
        }
        return counts
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 11) {
                    Text("Review")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.horizontal)
                    
                    // Rating Summary
                    HStack(alignment: .top, spacing: 22) {
                     
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    // Reviews List
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(reviews) { review in
                            ReviewCellView(review: review)
                                .padding(.horizontal)
                            Divider()
                                .padding(.horizontal)
                        }
                        
                        if !reviews.isEmpty {
                            Button(action: {
                                loadMoreReviews()
                            }) {
                                Text("Load More")
                                    .font(.system(size: 16, weight: .medium))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(UIColor.systemGreen))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)


        .onAppear {
            loadInitialReviews()
        }
    }
    
    // MARK: - Methods
    private func loadInitialReviews() {
        // Simulated initial data
        let sampleReviews = [
            Review(rating: 4.4, date: Date(timeIntervalSinceNow: -86400 * 2),
                  comment: "A peaceful and scenic spot! Loved waking up to misty mornings and exploring the nearby trails. Make sure to bring all your supplies as it's quite remote.",
                  authorName: "Carter Botosh"),
            Review(rating: 4.2, date: Date(timeIntervalSinceNow: -86400 * 3),
                  comment: "A peaceful and scenic spot! Loved waking up to misty mornings and exploring the nearby trails. Make sure to bring all your supplies as it's quite remote.",
                  authorName: "Jaxson Septimus"),
            Review(rating: 4.1, date: Date(timeIntervalSinceNow: -86400 * 4),
                  comment: "A peaceful and scenic spot! Loved waking up to misty mornings and exploring the nearby trails. Make sure to bring all your supplies as it's quite remote.",
                  authorName: "Carla Press")
        ]
        reviews = sampleReviews
    }
    
    private func loadMoreReviews() {
        isLoading = true
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Add more reviews here
            isLoading = false
        }
    }
}

// MARK: - Preview Provider
struct ReviewsScreen_Previews: PreviewProvider {
    static var previews: some View {
        ReviewsScreen()
    }
}
