//
//  CampingPreferenceView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-02.
//

import SwiftUI

struct CampingPreferenceView: View {
    @State private var selectedOption: CampingOption?
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToBudget = false
    
    enum CampingOption: String, CaseIterable {
        case freeCamping = "Free Camping"
        case paidCamping = "Paid Camping"
        case solo = "Solo Camping"
        case groupCamping = "Group Camping"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("How do you like to")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("camping?")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("What's your preference?")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(CampingOption.allCases, id: \.self) { option in
                        CampingOptionCard(
                            option: option,
                            isSelected: selectedOption == option,
                            action: { selectedOption = option }
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 10) {
                    NavigationLink(destination: BudgetPreferenceView(), isActive: $navigateToBudget) {
                        //EmptyView()
                    }
                    
                    Button(action: {
                        if selectedOption != nil {
                            navigateToBudget = true
                        }
                    }) {
                        Text("Next")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedOption != nil ? Color.green : Color.gray.opacity(0.3))
                            .foregroundColor(selectedOption != nil ? .white : .gray)
                            .cornerRadius(10)
                    }
                    .disabled(selectedOption == nil)
                    
                    Button("Skip") {
                        navigateToBudget = true
                    }
                    .foregroundColor(.gray)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct CampingOptionCard: View {
    let option: CampingPreferenceView.CampingOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 18) {
                Image(iconName(for: option))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 70)
                
                Text(option.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: isSelected ? .green.opacity(0.3) : .gray.opacity(0.2),
                            radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
    }
    
    private func iconName(for option: CampingPreferenceView.CampingOption) -> String {
        switch option {
        case .freeCamping:
            return "freecamping"
        case .paidCamping:
            return "paidcamping"
        case .solo:
            return "solocamping"
        case .groupCamping:
            return "groupcamping"
        }
    }
}

struct CampingPreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        CampingPreferenceView()
    }
}
