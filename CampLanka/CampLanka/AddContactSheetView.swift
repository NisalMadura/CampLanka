//
//  AddContactSheetView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-10-28.
//

import SwiftUI

struct ContactGroup: Identifiable {
    let id = UUID()
    var name: String
    var image: String
    var contacts: Int
    var imageType: ContactImageType
    
    enum ContactImageType {
        case system
        case custom
    }
}

struct AddContactSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var contactGroups: [ContactGroup]
    @State private var groupName: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Group Name", text: $groupName)
                }
                
                Section {
                    Button("Create Group") {
                        let newGroup = ContactGroup(
                            name: groupName,
                            image: "person.2.fill",
                            contacts: 0,
                            imageType: .system
                        )
                        contactGroups.append(newGroup)
                        dismiss()
                    }
                    .disabled(groupName.isEmpty)
                }
            }
            .navigationTitle("Add Circle")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
}

struct EmergencyCircleView: View {
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var showingDeleteAlert = false
    @State private var groupToDelete: ContactGroup?
    @State private var contactGroups = [
        ContactGroup(name: "General", image: "person.2.fill", contacts: 2, imageType: .system),
        ContactGroup(name: "Family", image: "person.3.fill", contacts: 5, imageType: .system),
        ContactGroup(name: "Relatives", image: "person.3.sequence.fill", contacts: 6, imageType: .system),
        ContactGroup(name: "Relatives 1", image: "person.2.fill", contacts: 2, imageType: .system)
    ]
    
    var filteredGroups: [ContactGroup] {
        if searchText.isEmpty {
            return contactGroups
        } else {
            return contactGroups.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Emergency circle")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    showingAddSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .foregroundColor(.orange)
                        Text("Add Circle")
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("search", text: $searchText)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                Image(systemName: "mic.fill")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 2)
            )
            .padding()
            
            // Contact Groups List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredGroups) { group in
                        ContactGroupRow(group: group)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    groupToDelete = group
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .onTapGesture {
                                groupToDelete = group
                                showingDeleteAlert = true
                            }
                    }
                }
                .padding()
            }
            
            Spacer()
            
            // Custom Tab Bar
            CustomTabBar()
        }
        .sheet(isPresented: $showingAddSheet) {
            AddContactSheet(contactGroups: $contactGroups)
        }
        .alert("Delete Group", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let group = groupToDelete,
                   let index = contactGroups.firstIndex(where: { $0.id == group.id }) {
                    contactGroups.remove(at: index)
                }
            }
        } message: {
            Text("Are you sure you want to delete this group?")
        }
    }
}

struct ContactGroupRow: View {
    let group: ContactGroup
    
    var body: some View {
        HStack {
            // Group Image
            ZStack {
                Circle()
                    .fill(group.name == "General" ? Color.green.opacity(0.2) :
                          group.name == "Family" ? Color.blue.opacity(0.2) :
                          group.name == "Relatives" ? Color.orange.opacity(0.2) :
                          Color.purple.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: group.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.black)
            }
            
            // Group Name
            Text(group.name)
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            // Contacts Count
            Text("\(group.contacts) Contacts")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 2)
        )
    }
}

// Preview Provider
struct EmergencyCircleView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyCircleView()
    }
}
