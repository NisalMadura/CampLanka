//
//  CustomTabBar.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-10-28.
//

import SwiftUI

// Tab Item Model
enum TabItem: Int, CaseIterable {
    case home = 0
    case favorite
    case addPlan
    case location
    case profile
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .favorite: return "Favorite"
        case .addPlan: return "Add Plan"
        case .location: return "Location"
        case .profile: return "Profile"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .favorite: return "heart"
        case .addPlan: return "plus"
        case .location: return "mappin.circle"
        case .profile: return "person"
        }
    }
}

// Reusable Custom Tab Bar
struct MainView: View {
    @State private var selectedTab: TabItem = .home
    private let darkGreen = Color(red: 0/255, green: 78/255, blue: 56/255)
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .home:
                    HomeViewscn()
                case .favorite:
                    WishListView()
                case .addPlan:
                    SaveToPlanView()
                case .location:
                    LocationView()
                case .profile:
                    ProfileView()
                }
            }
            
            // Top Divider
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.gray.opacity(0.3))
            
            // Tab Bar Content
            HStack(spacing: 0) {
                ForEach(TabItem.allCases, id: \.rawValue) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 20)
            .background(Color.white)
        }
    }
    
    @ViewBuilder
    private func tabButton(for tab: TabItem) -> some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack(spacing: 4) {
                if tab == .addPlan {
                    // Special Add Plan Button
                    ZStack {
                        Circle()
                            .fill(darkGreen)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: tab.icon)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .offset(y: -1)
                } else {
                    // Regular Tab Icons
                    Image(systemName: tab.icon)
                        .font(.system(size: 24))
                        .foregroundColor(selectedTab == tab ? darkGreen : .gray)
                }
                
                // Tab Title
                Text(tab.title)
                    .font(.system(size: 12))
                    .foregroundColor(selectedTab == tab ? darkGreen : .gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// Example Views with Enhanced Design
struct HomeView: View {
    var body: some View {
        NavigationView {
            Text("Home View")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Home")
        }
    }
}

struct FavoriteView: View {
    var body: some View {
        NavigationView {
            Text("Favorite View")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Favorites")
        }
    }
}

struct AddPlanView: View {
    var body: some View {
        NavigationView {
            Text("Add Plan View")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Add Plan")
        }
    }
}

struct LocationView: View {
    var body: some View {
        NavigationView {
            Text("Location View")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Location")
        }
    }
}

struct ProfileVoiew: View {
    var body: some View {
        NavigationView {
            Text("Profile View")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Profile")
        }
    }
}

// Custom View Modifiers
struct TabBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: -2)
    }
}

// Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
