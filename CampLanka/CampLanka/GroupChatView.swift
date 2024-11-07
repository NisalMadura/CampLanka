//
//  GroupChatView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-05.
//



import SwiftUI
import PhotosUI

// MARK: - Models
struct GroupMember: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
    let phoneNumber: String
    let profileImage: UIImage?
    var isAdmin: Bool
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Implement Equatable
    static func == (lhs: GroupMember, rhs: GroupMember) -> Bool {
        lhs.id == rhs.id
    }
}

struct GroupSettings: Equatable {
    var name: String
    var photo: UIImage?
    var members: [GroupMember]
    var muteNotifications: Bool
    var pinConversation: Bool
    var hideAlerts: Bool
    
    static func == (lhs: GroupSettings, rhs: GroupSettings) -> Bool {
        lhs.name == rhs.name &&
        lhs.members == rhs.members &&
        lhs.muteNotifications == rhs.muteNotifications &&
        lhs.pinConversation == rhs.pinConversation &&
        lhs.hideAlerts == rhs.hideAlerts
    }
}

// MARK: - View Model
class GroupSettingsViewModel: ObservableObject {
    @Published var settings: GroupSettings
    @Published var showingImagePicker = false
    @Published var showingAddMembers = false
    @Published var searchText = ""
    @Published var isEditingName = false
    
    init() {
        // Sample data
        self.settings = GroupSettings(
            name: "Canyon Club",
            photo: nil,
            members: [
                GroupMember(name: "Michael Tran", phoneNumber: "+1 (555) 123-4567", profileImage: nil, isAdmin: true),
                GroupMember(name: "Kristen Decastro", phoneNumber: "+1 (555) 234-5678", profileImage: nil, isAdmin: false),
                GroupMember(name: "Chris Johnson", phoneNumber: "+1 (555) 345-6789", profileImage: nil, isAdmin: false)
            ],
            muteNotifications: false,
            pinConversation: true,
            hideAlerts: false
        )
    }
    
    func addMember(_ member: GroupMember) {
        settings.members.append(member)
    }
    
    func removeMember(_ member: GroupMember) {
        settings.members.removeAll { $0.id == member.id }
    }
    
    func toggleAdmin(for member: GroupMember) {
        if let index = settings.members.firstIndex(where: { $0.id == member.id }) {
            settings.members[index].isAdmin.toggle()
        }
    }
    
    func leaveGroup() {
        // Handle leaving group
    }
}

// MARK: - Views
struct GroupSettingsView: View {
    @StateObject private var viewModel = GroupSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Group Info Section
                Section {
                    GroupInfoHeader(viewModel: viewModel)
                }
                
                // Media, Links & Docs Section
                Section {
                    NavigationLink("Media, Links & Docs") {
                        Text("Media Content View")
                    }
                }
                
                // Members Section
                Section {
                    ForEach(viewModel.settings.members) { member in
                        MemberRow(member: member, viewModel: viewModel)
                    }
                    
                    Button(action: { viewModel.showingAddMembers = true }) {
                        Label("Add Members", systemImage: "person.badge.plus")
                            .foregroundColor(.blue)
                    }
                } header: {
                    Text("MEMBERS (\(viewModel.settings.members.count))")
                }
                
                // Settings Section
                Section {
                    Toggle("Mute Notifications", isOn: $viewModel.settings.muteNotifications)
                    Toggle("Pin Conversation", isOn: $viewModel.settings.pinConversation)
                    Toggle("Hide Alerts", isOn: $viewModel.settings.hideAlerts)
                }
                
                // Leave Group Section
                Section {
                    Button(role: .destructive, action: viewModel.leaveGroup) {
                        Text("Leave Group")
                    }
                }
            }
            .navigationTitle("Group Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddMembers) {
            AddMembersView(viewModel: viewModel)
        }
    }
}

struct AddMembersView: View {
    @ObservedObject var viewModel: GroupSettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedContacts = Set<GroupMember>()
    
    // Sample contacts data
    let contacts = [
        GroupMember(name: "Alice Smith", phoneNumber: "+1 (555) 111-2222", profileImage: nil, isAdmin: false),
        GroupMember(name: "Bob Johnson", phoneNumber: "+1 (555) 222-3333", profileImage: nil, isAdmin: false),
        GroupMember(name: "Carol White", phoneNumber: "+1 (555) 333-4444", profileImage: nil, isAdmin: false)
    ]
    
    var filteredContacts: [GroupMember] {
        if viewModel.searchText.isEmpty {
            return contacts
        }
        return contacts.filter {
            $0.name.lowercased().contains(viewModel.searchText.lowercased()) ||
            $0.phoneNumber.contains(viewModel.searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    ForEach(filteredContacts) { contact in
                        ContactRow(contact: contact, isSelected: selectedContacts.contains(contact))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedContacts.contains(contact) {
                                    selectedContacts.remove(contact)
                                } else {
                                    selectedContacts.insert(contact)
                                }
                            }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .searchable(text: $viewModel.searchText, prompt: "Search")
            .navigationTitle("Add Members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        selectedContacts.forEach { viewModel.addMember($0) }
                        dismiss()
                    }
                    .disabled(selectedContacts.isEmpty)
                }
            }
        }
    }
}

// Supporting Views (GroupInfoHeader, MemberRow, ContactRow) remain the same
struct GroupInfoHeader: View {
    @ObservedObject var viewModel: GroupSettingsViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Group Photo
            Button(action: { viewModel.showingImagePicker = true }) {
                if let photo = viewModel.settings.photo {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .foregroundColor(.gray)
                        )
                }
            }
            
            // Group Name
            if viewModel.isEditingName {
                TextField("Group Name", text: $viewModel.settings.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .onSubmit { viewModel.isEditingName = false }
            } else {
                Text(viewModel.settings.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .onTapGesture { viewModel.isEditingName = true }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

struct MemberRow: View {
    let member: GroupMember
    @ObservedObject var viewModel: GroupSettingsViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            if let image = member.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(member.name.prefix(1)))
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(member.name)
                        .font(.system(size: 16, weight: .medium))
                    if member.isAdmin {
                        Text("Admin")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                Text(member.phoneNumber)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if !member.isAdmin {
                Menu {
                    Button(action: { viewModel.toggleAdmin(for: member) }) {
                        Label("Make Admin", systemImage: "person.badge.shield.checkmark")
                    }
                    Button(role: .destructive, action: { viewModel.removeMember(member) }) {
                        Label("Remove from Group", systemImage: "person.badge.minus")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ContactRow: View {
    let contact: GroupMember
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            if let image = contact.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(contact.name.prefix(1)))
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.system(size: 16, weight: .medium))
                Text(contact.phoneNumber)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview Provider
struct GroupSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GroupSettingsView()
    }
}