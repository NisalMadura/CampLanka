//
//  PreferredFacilitiesView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-03.
//

import SwiftUI

// MARK: - Models
struct Facility: Identifiable {
    let id = UUID()
    let name: String
    var isSelected: Bool
}

// MARK: - View Models
class FacilitiesViewModel: ObservableObject {
    @Published var facilities: [Facility] = [
        Facility(name: "Restrooms", isSelected: false),
        Facility(name: "Water supply", isSelected: true),
        Facility(name: "Electricity", isSelected: false),
        Facility(name: "Fire pits", isSelected: false),
        Facility(name: "BBQ", isSelected: false),
        Facility(name: "Wi-Fi", isSelected: false),
        Facility(name: "Pet-friendly", isSelected: false),
        Facility(name: "Parking", isSelected: false),
    ]
    
    func toggleFacility(_ facilityId: UUID) {
        if let index = facilities.firstIndex(where: { $0.id == facilityId }) {
            facilities[index].isSelected.toggle()
        }
    }
    
    func addNewFacility(_ name: String) {
        let facility = Facility(name: name, isSelected: false)
        facilities.append(facility)
    }
}

// MARK: - Views
struct PreferredFacilitiesView: View {
    @StateObject private var viewModel = FacilitiesViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAddFacility = false
    @State private var newFacilityName = ""
    
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
                    
                    Text("Preferred Facilities")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                
                Divider() // Add a
            // Facilities Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.facilities) { facility in
                        FacilityCell(
                            name: facility.name,
                            isSelected: facility.isSelected,
                            action: { viewModel.toggleFacility(facility.id) }
                        )
                    }
                    
                    // Add More Button
                    Button(action: {
                        showingAddFacility = true
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
            
            // Next Button
            Button(action: {
                // Handle next action
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((Color(red: 0/255, green: 84/255, blue: 64/255)))
                    .cornerRadius(25)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
                Button("Skip") {
                    // Handle skip action
                    //dismiss()
                    
                }
                .foregroundColor(.gray)
                Spacer()
        }
        .sheet(isPresented: $showingAddFacility) {
            AddFacilitySheet(
                newFacilityName: $newFacilityName,
                isPresented: $showingAddFacility,
                onAdd: { name in
                    viewModel.addNewFacility(name)
                }
            )
        }
    }
}

struct FacilityCell: View {
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
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
            )
        }
    }
}

struct AddFacilitySheet: View {
    @Binding var newFacilityName: String
    @Binding var isPresented: Bool
    let onAdd: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Facility Name", text: $newFacilityName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Add Facility") {
                    if !newFacilityName.isEmpty {
                        onAdd(newFacilityName)
                        newFacilityName = ""
                        isPresented = false
                    }
                }
                .foregroundColor(.green)
                .padding()
            }
            .navigationTitle("Add New Facility")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    isPresented = false
                }
            )
        }
    }
}

// MARK: - Preview
struct PreferredFacilitiesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferredFacilitiesView()
    }
}
