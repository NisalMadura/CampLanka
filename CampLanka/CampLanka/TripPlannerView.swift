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
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // StatusBarView()
                    
                    VStack(spacing: 0) {
                        Text("Trip Planner")
                            .font(.system(size: 24, weight: .bold))
                            .padding(.top, 20)
                        
                        Spacer().frame(height: 80)
                        
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
                        
                        NavigationLink(destination: CampingPreferenceView()) {
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
                    }
                }
            }
        }
    }
}



struct TripPlannerView_Previews: PreviewProvider {
    static var previews: some View {
        TripPlannerView()
    }
}

