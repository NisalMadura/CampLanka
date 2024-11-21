
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
import UserNotifications

struct ProfileView: View {
    @State private var selectedTab = 4
    @State private var showingEditProfile = false
    @State private var showingLogoutAlert = false
    @State private var isLoggedOut = false
    @State private var profileImage: UIImage?
    @State private var isLoading = false
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("userid") private var userid: String = ""
    @AppStorage("login_status") private var loginStatus: Bool = false
    @AppStorage("userName") private var userName: String = ""
    @State private var showingPersonalDetails = false
    @State private var showingAccountAndPassword = false
    @State private var showingHelpCenter = false
    @State private var showingNotificationSettings = false
    
    
    
    private let darkGreen = Color(red: 0/255, green: 78/255, blue: 56/255)
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    VStack(spacing: 24) {
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
                        
                        ZStack {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            }
                            
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .background(Color.black.opacity(0.4))
                                    .clipShape(Circle())
                                    .frame(width: 100, height: 100)
                            }
                        }
                        
                        Text(userName.isEmpty ? "Fetching Name..." : userName)
                            .font(.system(size: 24, weight: .semibold))
                            .padding(.bottom, 20)
                    }
                    
                    VStack(spacing: 0) {
                        MenuLink(title: "Personal Details", iconName: "person.fill") {showingPersonalDetails = true}
                        MenuLink(title: "Account & Password", iconName: "lock.fill") {showingAccountAndPassword = true}
                        MenuLink(title: "Notification Settings", iconName: "bell.fill") {showingNotificationSettings = true
                        }
                        MenuLink(title: "Help Center", iconName: "questionmark.circle.fill") {showingHelpCenter = true}
                        MenuLink(title: "Sign Out", iconName: "rectangle.portrait.and.arrow.right") {
                            showingLogoutAlert = true
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .background(Color(UIColor.systemBackground))
            }
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
                SignInSignUpView()
            }
            .onAppear {
                fetchUserData()
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(profileImage: $profileImage, userName: $userName)
        }
        .sheet(isPresented: $showingPersonalDetails) {
            PersonalDetailsView()
        }
        .sheet(isPresented: $showingAccountAndPassword) {
            AccountAndPasswordView()
        }
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView()
        }
        .sheet(isPresented: $showingHelpCenter) {
            HelpCenterView()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func fetchUserData() {
        isLoading = true
        fetchUserName()
        fetchProfileImage()
    }
    
    private func fetchUserName() {
        guard let userID = Auth.auth().currentUser?.uid else {
            userName = "Guest"
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { document, error in
            if let document = document, document.exists, let name = document.data()?["name"] as? String, !name.isEmpty {
                self.userName = name
            } else if let email = Auth.auth().currentUser?.email {
                self.userName = email.components(separatedBy: "@").first ?? "Unknown User"
            } else {
                self.userName = "Guest"
            }
        }
    }
    
    private func fetchProfileImage() {
        guard let userID = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let profileImageRef = storageRef.child("profile_images/\(userID).jpg")
        
        profileImageRef.getData(maxSize: Int64(5 * 1024 * 1024)) { data, error in
            isLoading = false
            
            if let error = error {
                print("Error downloading profile image: \(error)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            }
        }
    }
    
    private func logOut() {
        do {
            try Auth.auth().signOut()
            KeychainHelper.shared.delete(forKey: "uid")
            userName = ""
            userid = ""
            loginStatus = false
            profileImage = nil
            self.isLoggedOut = true
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}


struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var imagePickerItem: PhotosPickerItem?
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @Binding var profileImage: UIImage?
    @Binding var userName: String
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Photo")) {
                    HStack {
                        Spacer()
                        ZStack {
                            if let image = selectedImage ?? profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                                    .clipShape(Circle())
                            }
                            
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(width: 100, height: 100)
                                    .background(Color.black.opacity(0.4))
                                    .clipShape(Circle())
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    
                    PhotosPicker(selection: $imagePickerItem,
                                 matching: .images) {
                        Text("Change Photo")
                            .foregroundColor(.blue)
                    }
                                 .onChange(of: imagePickerItem) { oldValue, newValue in
                                     Task {
                                         if let data = try? await newValue?.loadTransferable(type: Data.self),
                                            let image = UIImage(data: data) {
                                             await MainActor.run {
                                                 selectedImage = image
                                             }
                                         }
                                     }
                                 }
                }
                
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                        .autocapitalization(.words)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(isSaving ? "Saving..." : "Save") {
                    saveProfile()
                }
                    .disabled(isSaving || (name.isEmpty && selectedImage == nil))
            )
            .alert(isPresented: $showingErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            name = userName
        }
    }
    
    private func saveProfile() {
        guard let userID = Auth.auth().currentUser?.uid else {
            showError("User not authenticated")
            return
        }
        
        isSaving = true
        
        let group = DispatchGroup()
        var hadError = false
        
        
        if let imageToUpload = selectedImage {
            group.enter()
            uploadProfileImage(imageToUpload, userID: userID) { result in
                switch result {
                case .success():
                    self.profileImage = imageToUpload
                case .failure(let error):
                    hadError = true
                    showError("Failed to upload image: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        
        if !name.isEmpty && name != userName {
            group.enter()
            let db = Firestore.firestore()
            db.collection("users").document(userID).setData(["name": name], merge: true) { error in
                if let error = error {
                    hadError = true
                    showError("Failed to save name: \(error.localizedDescription)")
                } else {
                    userName = name
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            isSaving = false
            if !hadError {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func uploadProfileImage(_ image: UIImage, userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let profileImageRef = storageRef.child("profile_images/\(userID).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        profileImageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingErrorAlert = true
    }
}


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
                    .foregroundColor(.primary)
                
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


class KeychainHelpers {
    static let shared = KeychainHelpers()
    private init() {}
    
    func save(_ data: Data, forKey key: String) {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func delete(forKey key: String) {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
    }
    
}

struct NotificationSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var pushNotifications = false
    @State private var emailNotifications = false
    @State private var isLoading = true
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notification Preferences")) {
                    Toggle(isOn: $pushNotifications) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.blue)
                            Text("Push Notifications")
                        }
                    }
                    .onChange(of: pushNotifications) { oldValue, newValue in
                        updateNotificationSettings(type: "push", enabled: newValue)
                    }
                    
                    Toggle(isOn: $emailNotifications) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.blue)
                            Text("Email Notifications")
                        }
                    }
                    .onChange(of: emailNotifications) { oldValue, newValue in
                        updateNotificationSettings(type: "email", enabled: newValue)
                    }
                }
                
                Section(header: Text("About Notifications"), footer: Text("Push notifications may include camping alerts, booking confirmations, and important updates. Email notifications include weekly newsletters and promotional offers.")) {
                    NavigationLink(destination: NotificationHistoryView()) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                            Text("Notification History")
                        }
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarItems(leading: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                fetchNotificationSettings()
                requestNotificationPermissions()
            }
        }
    }
    
    private func fetchNotificationSettings() {
        guard let userID = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { document, error in
            isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                pushNotifications = data?["pushNotificationsEnabled"] as? Bool ?? false
                emailNotifications = data?["emailNotificationsEnabled"] as? Bool ?? false
            }
        }
    }
    
    private func updateNotificationSettings(type: String, enabled: Bool) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let field = type == "push" ? "pushNotificationsEnabled" : "emailNotificationsEnabled"
        
        db.collection("users").document(userID).setData([
            field: enabled
        ], merge: true) { error in
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permissions: \(error)")
            }
        }
    }
}


struct NotificationHistoryView: View {
    @State private var notifications: [NotificationItem] = []
    @State private var isLoading = true
    
    var body: some View {
        List {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if notifications.isEmpty {
                Text("No notifications yet")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(notifications) { notification in
                    NotificationItemView(notification: notification)
                }
            }
        }
        .navigationTitle("Notification History")
        .onAppear {
            fetchNotificationHistory()
        }
    }
    
    private func fetchNotificationHistory() {
        guard let userID = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(userID)
            .collection("notifications")
            .order(by: "timestamp", descending: true)
            .limit(to: 50)
            .addSnapshotListener { querySnapshot, error in
                isLoading = false
                
                if let error = error {
                    print("Error fetching notifications: \(error)")
                    return
                }
                
                notifications = querySnapshot?.documents.compactMap { document -> NotificationItem? in
                    let data = document.data()
                    return NotificationItem(
                        id: document.documentID,
                        title: data["title"] as? String ?? "",
                        message: data["message"] as? String ?? "",
                        type: data["type"] as? String ?? "",
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                        isRead: data["isRead"] as? Bool ?? false
                    )
                } ?? []
            }
    }
}


struct NotificationItem: Identifiable {
    let id: String
    let title: String
    let message: String
    let type: String
    let timestamp: Date
    let isRead: Bool
}


struct NotificationItemView: View {
    let notification: NotificationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: notification.type == "push" ? "bell.fill" : "envelope.fill")
                    .foregroundColor(.blue)
                Text(notification.title)
                    .font(.headline)
                Spacer()
                Text(timeAgo(from: notification.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(notification.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .opacity(notification.isRead ? 0.8 : 1.0)
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
