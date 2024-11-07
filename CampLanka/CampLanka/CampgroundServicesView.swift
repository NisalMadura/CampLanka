//
//  CampgroundServicesView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-04.
//

import SwiftUI

struct CampgroundServicesView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Model for service cards
    struct ServiceCard: Identifiable {
        let id = UUID()
        let title: String
        let contactNumber: String
        let imageUrl: String
        let isVerified: Bool
        let isFeatured: Bool
    }
    
    // Sample data
    let services = [
        ServiceCard(
            title: "Tent Rental",
            contactNumber: "+94 777 123456",
            imageUrl: "serviceimg1",
            isVerified: true,
            isFeatured: true
        ),
        ServiceCard(
            title: "Local Guide Services",
            contactNumber: "+94 777 123456",
            imageUrl: "serviceimg2",
            isVerified: false,
            isFeatured: true
            
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                // Navigation Bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                            Text("Back")
                                .foregroundColor(.blue)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                // Title
                HStack {
                    Text("Campground Services")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // Services List
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(services) { service in
                        ServiceCardView(service: service)
                    }
                }
                .padding()
            }
            
            // Using your existing CustomTabBar
           // CustomTabBar()
        }
    }
}

// Service Card View
struct ServiceCardView: View {
    let service: CampgroundServicesView.ServiceCard
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background Image
            Image(service.imageUrl)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
                .cornerRadius(12)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.5), Color.clear]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            
            // Content Overlay
            VStack(alignment: .leading, spacing: 8) {
                // Tags
                HStack(spacing: 8) {
                    if service.isVerified {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.white)
                            Text("Verified")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.7))
                        .cornerRadius(12)
                    }
                    
                    if service.isFeatured {
                        Text("Featured")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 12)
                
                Spacer()
                
                // Title and Contact
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Contact: \(service.contactNumber)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
                
                // View Button
                Button(action: {
                    // Handle view action
                    callPhoneNumber(service.contactNumber)
                }) {
                    Text("View")
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .frame(width: 80)
                        .padding(.vertical, 8)
                        .background(Color.yellow)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .frame(maxWidth: .infinity)
        .shadow(radius: 5)
    }
    
    // Function to handle phone call
    private func callPhoneNumber(_ number: String) {
        let cleanNumber = number.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(cleanNumber)") {
            UIApplication.shared.open(url)
        }
    }
}

// Preview Provider
struct CampgroundServicesView_Previews: PreviewProvider {
    static var previews: some View {
        CampgroundServicesView()
    }
}
