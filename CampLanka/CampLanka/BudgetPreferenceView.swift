//
//  BudgetPreferenceView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-02.
//

import SwiftUI

struct BudgetPreferenceView: View {
    @State private var selectedOption: BudgetOption?
    @State private var navigateToFacilities = false
    
    enum BudgetOption: String, CaseIterable {
        case budgetFriendly = "Budget-friendly"
        case moderate = "Moderate"
        case luxury = "Luxury"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            VStack(alignment: .center, spacing: 36) {
                Text("Budget Preferences")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("What are your budget preferences?")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            
            
            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    BudgetOptionCard(
                        option: .budgetFriendly,
                        isSelected: selectedOption == .budgetFriendly,
                        action: { selectedOption = .budgetFriendly }
                    )
                    
                    BudgetOptionCard(
                        option: .moderate,
                        isSelected: selectedOption == .moderate,
                        action: { selectedOption = .moderate }
                    )
                }
                
                BudgetOptionCard(
                    option: .luxury,
                    isSelected: selectedOption == .luxury,
                    action: { selectedOption = .luxury }
                )
                .frame(width: UIScreen.main.bounds.width * 0.45)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 28) {
                
                Button(action: {
                    if selectedOption != nil {
                        navigateToFacilities = true
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
                
                
                Button(action: {
                    navigateToFacilities = true
                }) {
                    Text("Skip")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            
            NavigationLink(
                destination: PreferredFacilitiesView(),
                isActive: $navigateToFacilities,
                label: { EmptyView() }
            )
        }
        .navigationBarBackButtonHidden(true)
    }
}


struct BudgetOptionCard: View {
    let option: BudgetPreferenceView.BudgetOption
    let isSelected: Bool
    let action: () -> Void
    
    var iconName: String {
        switch option {
        case .budgetFriendly:
            return "budgetfriendly"
        case .moderate:
            return "moderate"
        case .luxury:
            return "luxury"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 39) {
                Image(iconName)
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
}

struct BudgetPreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetPreferenceView()
    }
}
