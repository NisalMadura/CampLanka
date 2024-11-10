import SwiftUI
import Firebase
import FirebaseAuth

struct ProfileView: View {
    @State private var selectedTab = 4  // Profile tab selected
    @State private var showingEditProfile = false
    @State private var showingLogoutAlert = false
    @State private var isLoggedOut = false
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("userid") private var userid: String = ""
    @AppStorage("login_status") private var loginStatus: Bool = false
    @AppStorage("userName") private var userName: String = ""
    
    private let darkGreen = Color(red: 0/255, green: 78/255, blue: 56/255)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Profile Section
                VStack(spacing: 24) {
                    // Edit Button
                    HStack {
                        Spacer()
                        Button(action: {
                            showingEditProfile = true
                        }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                                .padding(12)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.top, 10)
                    
                    // Profile Image
                    Image("profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    
                    // Name
                    Text(userName.isEmpty ? "Nisal Perera" : userName)
                        .font(.system(size: 24, weight: .semibold))
                        .padding(.bottom, 20)
                }
                
                // Menu Items
                VStack(spacing: 0) {
                    MenuLink(title: "Personal Details", iconName: "person.fill") {
                        print("Navigate to Personal Details")
                    }
                    
                    MenuLink(title: "Account & Password", iconName: "lock.fill") {
                        print("Navigate to Account & Password")
                    }
                    
                    MenuLink(title: "Help Center", iconName: "questionmark.circle.fill") {
                        print("Navigate to Help Center")
                    }
                    
                    MenuLink(title: "Sign Out", iconName: "rectangle.portrait.and.arrow.right") {
                        showingLogoutAlert = true
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .background(Color(UIColor.systemBackground))
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("Sign Out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign Out")) {
                        logOut()
                    },
                    secondaryButton: .cancel()
                )
            }
            .fullScreenCover(isPresented: $isLoggedOut) {
                // Navigate to your SignInView
                SignInView()
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
    }
    
    private func logOut() {
        do {
            // Sign out from Firebase
            try Auth.auth().signOut()
            
            // Clear user session data
            KeychainHelper.shared.delete(forKey: "uid")
            userName = ""
            userid = ""
            
            // Mark user as logged out and trigger navigation
            loginStatus = false
            self.isLoggedOut = true
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

// Menu Link Component
struct MenuLink: View {
    let title: String
    let iconName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 17))
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 24)
            .frame(height: 50)
        }
        Divider()
            .padding(.leading, 24)
    }
}

// Edit Profile View
struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = "Elisa Maria"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Photo")) {
                    HStack {
                        Spacer()
                        Image("profile-placeholder")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    
                    Button("Change Photo") {
                        // Handle photo change
                    }
                    .foregroundColor(.blue)
                }
                
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    // Handle save
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
