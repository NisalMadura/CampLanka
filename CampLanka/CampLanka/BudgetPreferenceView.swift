//
//  BudgetPreferenceView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-02.
//

import SwiftUI

struct BudgetPreferenceView: View {
    @State private var selectedOption: BudgetOption?
    @Environment(\.presentationMode) var presentationMode
    
    enum BudgetOption: String, CaseIterable {
        case budgetFriendly = "Budget-friendly"
        case moderate = "Moderate"
        case luxury = "Luxury"
    }
    
    // Grid layout setup
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Back Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                    Text("Back")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Title Section
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
            
            // Budget Options
            VStack(spacing: 20) {
                // First row with two options
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
                
                // Second row with single centered option
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
            
            VStack(spacing: 8) {
                // Next Button
                Button(action: {
                    // Handle next action
                    if selectedOption != nil {
                        // Navigate to next screen
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
                
                // Skip Text Button
                Button(action: {
                    // Handle skip action
                    // Navigate to next screen without selection
                }) {
                    Text("Skip")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            CustomTabBar()
        }
    }
}

struct BudgetOptionCard: View {
    let option: BudgetPreferenceView.BudgetOption
    let isSelected: Bool
    let action: () -> Void
    
    var iconName: String {
        switch option {
        case .budgetFriendly:
            return "budgetfriendly" // Replace with your actual asset name
        case .moderate:
            return "moderate" // Replace with your actual asset name
        case .luxury:
            return "luxury" // Replace with your actual asset name
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

// Preview Provider
struct BudgetPreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetPreferenceView()
    }
}
