//
//  TripPlannerView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-10-27.
//

import SwiftUI


struct TripPlannerView: View {
    @State private var selectedTab = 0
    
    private let darkGreen = Color(red: 0/255, green: 78/255, blue: 56/255)
    
    var body: some View {
        ZStack {
            // Background color
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Status Bar content (Time, Battery, etc.)
                StatusBarView()
                
                // Main Content
                VStack(spacing: 0) {
                    Text("Trip Planner")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.top, 20)
                    
                    Spacer().frame(height: 80)
                    
                    // Tent Icon
                    Image("camplogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .padding(.top, 60)
                        .frame(width: 100, height: 100)
                    
                    Spacer().frame(height: 60)
                    
                    Text("Plan ahead")
                        .font(.system(size: 24, weight: .semibold))
                    
                    Text("Plan your camping trips with ease. Choose\ncampsites from personalized recommendations\nand schedule them for the perfect adventure\ndays.")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                        .padding(.top, 16)
                    
                    // Start Planning Button
                    Button(action: {}) {
                        Text("Start Planning")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(width: UIScreen.main.bounds.width - 48)
                            .background(darkGreen)
                            .cornerRadius(25)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Custom Tab Bar
                //    CustomTabBar(selectedTab: $selectedTab)
                    CustomTabBar()
                }
            }
        }
    }
}

// Status Bar View
struct StatusBarView: View {
    var body: some View {
        HStack {
            
                
            Spacer()
            HStack(spacing: 4) {
               
              
                
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 5)
        .frame(height: 44)
        .background(Color.white)
    }
}

// Tent Icon
struct TentIcon: View {
    private let darkGreen = Color(red: 0/255, green: 78/255, blue: 56/255)
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let peakPoint = CGPoint(x: width/2, y: height * 0.2)
                let leftBase = CGPoint(x: width * 0.15, y: height * 0.8)
                let rightBase = CGPoint(x: width * 0.85, y: height * 0.8)
                
                // Draw tent triangle
                path.move(to: leftBase)
                path.addLine(to: peakPoint)
                path.addLine(to: rightBase)
                
                // Draw base line
                path.move(to: CGPoint(x: width * 0.1, y: height * 0.8))
                path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.8))
            }
            .stroke(darkGreen, lineWidth: 8)
        }
    }
}
/*
// Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    private let darkGreen = Color(red: 0/255, green: 78/255, blue: 56/255)
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.gray.opacity(0.3))
            
            HStack(spacing: 0) {
                ForEach(0..<5) { index in
                    VStack(spacing: 4) {
                        if index == 2 { // Add Plan button
                            ZStack {
                                Circle()
                                    .fill(darkGreen)
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .offset(y: -1)
                            Text("Add Plan")
                                .font(.system(size: 12))
                                .foregroundColor(selectedTab == index ? darkGreen : .gray)
                        } else {
                            Image(systemName: getIcon(for: index))
                                .font(.system(size: 24))
                                .foregroundColor(selectedTab == index ? darkGreen : .gray)
                            Text(getTitle(for: index))
                                .font(.system(size: 12))
                                .foregroundColor(selectedTab == index ? darkGreen : .gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        selectedTab = index
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 20)
            .background(Color.white)
        }
    }
    
    private func getIcon(for index: Int) -> String {
        switch index {
        case 0: return "house.fill"
        case 1: return "heart"
        case 3: return "mappin.circle"
        case 4: return "person"
        default: return ""
        }
    }
    
    private func getTitle(for index: Int) -> String {
        switch index {
        case 0: return "Home"
        case 1: return "Favorite"
        case 2: return "Add Plan"
        case 3: return "Location"
        case 4: return "Profile"
        default: return ""
        }
    }
}

*/

#if DEBUG
// Helper Preview Provider
struct TripPlannerView_Previews: PreviewProvider {
    static var previews: some View {
        TripPlannerView()
    }
}
#endif
