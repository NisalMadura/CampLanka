//
//  ActivitiesPreferencesView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-03.
//

import SwiftUI

// MARK: - Models
struct Activity: Identifiable {
    let id = UUID()
    let name: String
    var isSelected: Bool
}

// MARK: - View Models
class ActivitiesViewModel: ObservableObject {
    @Published var activities: [Activity] = [
        Activity(name: "Hiking trails", isSelected: false),
        Activity(name: "Water activities", isSelected: true),
        Activity(name: "Wildlife watching", isSelected: false),
        Activity(name: "Campfires", isSelected: false),
        Activity(name: "Stargazing", isSelected: false),
        Activity(name: "Adventure sports", isSelected: false)
    ]
    
    func toggleActivity(_ activityId: UUID) {
        if let index = activities.firstIndex(where: { $0.id == activityId }) {
            activities[index].isSelected.toggle()
        }
    }
    
    func addNewActivity(_ name: String) {
        let activity = Activity(name: name, isSelected: false)
        activities.append(activity)
    }
    
    var hasSelectedActivities: Bool {
        activities.contains(where: { $0.isSelected })
    }
}

// MARK: - Views
struct ActivitiesPreferencesView: View {
    @StateObject private var viewModel = ActivitiesViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAddActivity = false
    @State private var newActivityName = ""
    @State private var showingAlert = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Navigation Bar with Centered Title
            ZStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                            Text("Back")
                                .foregroundColor(.blue)
                        }
                    }
                    Spacer()
                }
                
                Text("Activities Preferences")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            
            Divider()
            
            // Activities Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.activities) { activity in
                        ActivityCell(
                            name: activity.name,
                            isSelected: activity.isSelected,
                            action: { viewModel.toggleActivity(activity.id) }
                        )
                    }
                    
                    // Add More Button
                    Button(action: {
                        showingAddActivity = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor((Color(red: 0/255, green: 84/255, blue: 64/255)))
                            Text("Add More")
                                .foregroundColor((Color(red: 0/255, green: 84/255, blue: 64/255)))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
                        )
                    }
                }
                .padding()
            }
            
            Spacer()
            
            // Navigation Buttons
            VStack(spacing: 12) {
                Button(action: {
                    if viewModel.hasSelectedActivities {
                        // Handle next action here
                        print("Next button tapped")
                    } else {
                        showingAlert = true
                    }
                }) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background((Color(red: 0/255, green: 84/255, blue: 64/255)))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    // Handle skip action here
                    print("Skip button tapped")
                }) {
                    Text("Skip")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showingAddActivity) {
            AddActivitySheet(
                newActivityName: $newActivityName,
                isPresented: $showingAddActivity,
                onAdd: { name in
                    viewModel.addNewActivity(name)
                }
            )
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("No Activities Selected"),
                message: Text("Please select at least one activity to continue."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct ActivityCell: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "square")
                        .foregroundColor(.gray)
                }
                
                Text(name)
                    .foregroundColor(.black)
                    .font(.system(size: 16))
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
            )
        }
    }
}

struct AddActivitySheet: View {
    @Binding var newActivityName: String
    @Binding var isPresented: Bool
    let onAdd: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Activity Name", text: $newActivityName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Add Activity") {
                    if !newActivityName.isEmpty {
                        onAdd(newActivityName)
                        newActivityName = ""
                        isPresented = false
                    }
                }
                .foregroundColor(.green)
                .padding()
            }
            .navigationTitle("Add New Activity")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    isPresented = false
                }
            )
        }
    }
}

// MARK: - Preview
struct ActivitiesPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        ActivitiesPreferencesView()
    }
}
