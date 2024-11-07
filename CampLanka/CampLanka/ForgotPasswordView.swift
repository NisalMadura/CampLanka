//
//  ForgotPasswordView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-07.
//


import SwiftUI
import AuthenticationServices
import Firebase
import CryptoKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isLoading: Bool = false
    @State private var nonce: String?
    @State private var navigateToHome: Bool = false
    @AppStorage("log_status") private var logStatus: Bool = false
    @State private var showResetPassword: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Logo
                Image("camplogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .padding(.top, 60)
                
                // Title
                Text("Reset Password")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                // Description
                Text("Please enter your Email")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(.gray))
                    .padding(.horizontal, 32)
                TextField("Email", text: $email)
                                   .textInputAutocapitalization(.never)
                                   .keyboardType(.emailAddress)
                                   .padding()
                                   .cornerRadius(10)
                                   .overlay(
                                       RoundedRectangle(cornerRadius: 8)
                                           .stroke(Color(.systemGray3), lineWidth: 2)
                                   )
                                   .padding(.horizontal, 20)
                               
                              // Spacer().frame(height: 20)
                               
                             
                Button(action: {
                       handlePasswordReset()
                    }) {
                        HStack {
                          
                                
                            Text("Reset")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0/255, green: 84/255, blue: 64/255)) // Dark Green
                        .cornerRadius(25)
                    }
                    .padding(.horizontal, 24)
                    
                               
          
                .padding(.horizontal, 24)
                .padding(.top, 32)
                
                // Terms and Privacy
                VStack(alignment: .center, spacing: 4) {
                    Text("By continuing, you agree to our")
                        .foregroundColor(.black)
                        .font(.system(size: 14))
                    HStack {
                        Text("Terms of Use")
                            .foregroundColor(.blue)
                            .underline()
                            .font(.system(size: 14))
                        Text("and")
                            .foregroundColor(.black)
                            .font(.system(size: 14))
                        Text("Privacy Policy")
                            .foregroundColor(.blue)
                            .underline()
                            .font(.system(size: 14))
                    }
                }
                .padding(.bottom, 100)
                
                // Error Message Alert
                .alert(errorMessage, isPresented: $showAlert) { }
                
                // Loading Overlay
                .overlay {
                    if isLoading {
                        LoadingScreen()
                    }
                }
                .navigationDestination(isPresented: $navigateToHome) {
                    MainView()
                        .navigationBarBackButtonHidden(true)
                }
            }
            .background(Color.white)
        }
    }
    private func handlePasswordReset() {
            guard !email.isEmpty else {
                showError("Please enter your email")
                return
            }
            
            isLoading = true
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                isLoading = false
                if let error = error {
                    showError(error.localizedDescription)
                    return
                }
                
                showError("Password reset email sent successfully")
            }
        }

    
        
   
    @ViewBuilder
    func LoadingScreen() -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
            
            ProgressView()
                .frame(width: 45, height: 45)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(.systemBackground))
                )
        }
    }
    
    func showError(_ message: String) {
        errorMessage = message
        showAlert.toggle()
        isLoading = false
    }

   
    private func randomNonceString(length: Int = 32) -> String {
            precondition(length > 0)
            var randomBytes = [UInt8](repeating: 0, count: length)
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            
            let charset: [Character] =
                Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
            
            let nonce = randomBytes.map { byte in
                charset[Int(byte) % charset.count]
            }
            
            return String(nonce)
        }
        
        private func sha256(_ input: String) -> String {
            let inputData = Data(input.utf8)
            let hashedData = SHA256.hash(data: inputData)
            let hashString = hashedData.compactMap {
                String(format: "%02x", $0)
            }.joined()
            
            return hashString
        }
    
    
}


// Preview
struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
    ForgotPasswordView()
    }
}

// Custom button style
struct dSocialButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundColor)
            .cornerRadius(25)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}
