//
//  AccountAndPasswordView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-17.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct AccountAndPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showChangePassword = false
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showDeleteAccountAlert = false
    @State private var showingSuccessToast = false
    @State private var showCurrentPassword = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    
    var body: some View {
        NavigationView {
            Form {
                // Account Information Section
                Section(header: Text("Account Information")) {
                    if let user = Auth.auth().currentUser {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email ?? "No email")
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Account Created")
                            Spacer()
                            Text(formattedDate(user.metadata.creationDate))
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Last Sign In")
                            Spacer()
                            Text(formattedDate(user.metadata.lastSignInDate))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .headerProminence(.increased)
                
                // Password Change Section
                Section(header: Text("Change Password")) {
                    if !showChangePassword {
                        Button(action: {
                            showChangePassword = true
                        }) {
                            Text("Change Password")
                                .foregroundColor(.blue)
                        }
                    } else {
                        HStack {
                            SecureField("Current Password", text: $currentPassword)
                            Button(action: {
                                showCurrentPassword.toggle()
                            }) {
                                Image(systemName: showCurrentPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        HStack {
                            SecureField("New Password", text: $newPassword)
                            Button(action: {
                                showNewPassword.toggle()
                            }) {
                                Image(systemName: showNewPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        HStack {
                            SecureField("Confirm New Password", text: $confirmPassword)
                            Button(action: {
                                showConfirmPassword.toggle()
                            }) {
                                Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Button(action: changePassword) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Update Password")
                            }
                        }
                        .disabled(isLoading || !isValidPasswordInput())
                        .foregroundColor(isValidPasswordInput() ? .blue : .gray)
                    }
                }
                .headerProminence(.increased)
                
                // Password Requirements
                if showChangePassword {
                    Section(header: Text("Password Requirements")) {
                        PasswordRequirementRow(text: "At least 8 characters long",
                                            isMet: newPassword.count >= 8)
                        PasswordRequirementRow(text: "Contains uppercase letter",
                                            isMet: newPassword.contains(where: { $0.isUppercase }))
                        PasswordRequirementRow(text: "Contains number",
                                            isMet: newPassword.contains(where: { $0.isNumber }))
                        PasswordRequirementRow(text: "Passwords match",
                                            isMet: !newPassword.isEmpty && newPassword == confirmPassword)
                    }
                }
                
                // Account Actions Section
                Section(header: Text("Account Actions")) {
                    Button(action: {
                        showDeleteAccountAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Delete Account")
                                .foregroundColor(.red)
                        }
                    }
                }
                .headerProminence(.increased)
            }
            .navigationTitle("Account & Password")
            .navigationBarItems(
                leading: Button("Close") {
                    if showChangePassword && hasUnsavedChanges() {
                        // Show confirmation dialog
                        showDiscardChangesAlert()
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .confirmationDialog(
                "Delete Account",
                isPresented: $showDeleteAccountAlert,
                actions: {
                    Button("Delete Account", role: .destructive, action: deleteAccount)
                    Button("Cancel", role: .cancel) { }
                },
                message: {
                    Text("This action cannot be undone. All your data will be permanently deleted.")
                }
            )
            .overlay {
                if showingSuccessToast {
                    SuccessToast(message: "Password updated successfully")
                        .transition(.move(edge: .top))
                        .animation(.spring(), value: showingSuccessToast)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showingSuccessToast = false
                            }
                        }
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "Never" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func isValidPasswordInput() -> Bool {
        return !currentPassword.isEmpty &&
               newPassword.count >= 8 &&
               newPassword.contains(where: { $0.isUppercase }) &&
               newPassword.contains(where: { $0.isNumber }) &&
               newPassword == confirmPassword
    }
    
    private func hasUnsavedChanges() -> Bool {
        return !currentPassword.isEmpty || !newPassword.isEmpty || !confirmPassword.isEmpty
    }
    
    private func showDiscardChangesAlert() {
        alertTitle = "Discard Changes"
        alertMessage = "Are you sure you want to discard your changes?"
        showingAlert = true
    }
    
    private func changePassword() {
        isLoading = true
        
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            showError(title: "Error", message: "Please sign in again to change your password.")
            isLoading = false
            return
        }
        
        // First, reauthenticate the user
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                isLoading = false
                showError(title: "Authentication Failed",
                         message: "Please check your current password and try again.")
                print("Debug error: \(error.localizedDescription)")
                return
            }
            
            // Then update the password
            user.updatePassword(to: newPassword) { error in
                isLoading = false
                
                if let error = error {
                    showError(title: "Password Update Failed",
                             message: "Unable to update your password. Please try again later.")
                    print("Debug error: \(error.localizedDescription)")
                } else {
                    // Success
                    showingSuccessToast = true
                    currentPassword = ""
                    newPassword = ""
                    confirmPassword = ""
                    showChangePassword = false
                }
            }
        }
    }
    
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            showError(title: "Error", message: "Please sign in again to delete your account.")
            return
        }
        
        user.delete { error in
            if let error = error {
                showError(title: "Account Deletion Failed",
                         message: "Unable to delete your account. Please try again later.")
                print("Debug error: \(error.localizedDescription)")
            } else {
                // Handle successful account deletion
                // You might want to navigate to the sign-in screen or update app state
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func showError(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

struct PasswordRequirementRow: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? .green : .gray)
            Text(text)
                .foregroundColor(isMet ? .primary : .gray)
        }
    }
}

struct SuccessToast: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(message)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 4)
        .padding(.top, 20)
    }
}

struct AccountAndPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        AccountAndPasswordView()
    }
}
