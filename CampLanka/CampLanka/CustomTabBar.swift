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

// Tab Bar State Manager
class TabBarStateManager: ObservableObject {
    static let shared = TabBarStateManager()
    @Published var selectedTab: TabItem = .home
    
    private init() {} // Singleton
}

// Reusable Custom Tab Bar
struct CustomTabBar: View {
    @ObservedObject private var stateManager = TabBarStateManager.shared
    private let darkGreen = Color(red: 0/255, green: 78/255, blue: 56/255)
    
    var body: some View {
        VStack(spacing: 0) {
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
            stateManager.selectedTab = tab
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
                        .foregroundColor(stateManager.selectedTab == tab ? darkGreen : .gray)
                }
                
                // Tab Title
                Text(tab.title)
                    .font(.system(size: 12))
                    .foregroundColor(stateManager.selectedTab == tab ? darkGreen : .gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// Example of how to use in a View
struct MainView: View {
    @StateObject private var tabStateManager = TabBarStateManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Content based on selected tab
            switch tabStateManager.selectedTab {
            case .home:
                HomeView()
            case .favorite:
                FavoriteView()
            case .addPlan:
                AddPlanView()
            case .location:
                LocationView()
            case .profile:
                ProfileView()
            }
            
            // Custom Tab Bar
            CustomTabBar()
        }
    }
}

// Example Views
struct HomeView: View {
    var body: some View {
        Text("Home View")
    }
}

struct FavoriteView: View {
    var body: some View {
        Text("Favorite View")
    }
}

struct AddPlanView: View {
    var body: some View {
        Text("Add Plan View")
    }
}

struct LocationView: View {
    var body: some View {
        Text("Location View")
    }
}

/*struct ProfileView: View {
    var body: some View {
        Text("Profile View")
            .frame(maxHeight: .infinity)
            .background(Color.white)
    }
}*/

// Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
