//
//  SignInSignUpView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-10-27.
//

import SwiftUI
import AuthenticationServices
import Firebase
import CryptoKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import LocalAuthentication

struct SignInSignUpView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isLoading: Bool = false
    @State private var nonce: String?
    @State private var navigateToHome: Bool = false
    @AppStorage("log_status") private var logStatus: Bool = false
    @State private var showResetPassword: Bool = false
    @State private var biometryType: LABiometryType = .none
    @State private var isBiometricAvailable: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    init() {
        checkBiometricAvailability()
    }
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                Image("camplogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .padding(.top, 15)
                
                
                Text("Sign In")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                
                Text("Join CampLanka to discover campsites!")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(.gray))
                    .padding(.horizontal, 32)
                
                
                if isBiometricAvailable {
                    Button(action: {
                        authenticateWithBiometric()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: biometryType == .faceID ? "faceid" : "touchid")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                            
                            Text("Sign in with \(biometryType == .faceID ? "Face ID" : "Touch ID")")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0/255, green: 84/255, blue: 64/255))
                        .cornerRadius(25)
                    }
                    .padding(.horizontal, 24)
                }
                
                
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
                
                
                SecureField("Password", text: $password)
                    .padding()
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray3), lineWidth: 2)
                    )
                    .padding(.horizontal, 20)
                
                
                HStack {
                    Spacer()
                    Button(action: {
                        showResetPassword = true
                    }) {
                        Text("Forgot password?")
                            .foregroundColor(.blue)
                            .font(.footnote)
                            .padding(.horizontal, 5)
                            .padding(.top, 1)
                    }
                    .padding(.trailing)
                }
                
                
                NavigationLink(destination: ForgotPasswordView(), isActive: $showResetPassword) {
                    EmptyView()
                }
                
                // Sign In Button
                Button(action: {
                    handleEmailPasswordSignIn()
                }) {
                    HStack {
                        Text("Sign In")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0/255, green: 84/255, blue: 64/255))
                    .cornerRadius(25)
                }
                .padding(.horizontal, 24)
                
                
                VStack(spacing: 16) {
                    // Apple Login
                    SignInWithAppleButton(.signIn) { request in
                        let nonce = randomNonceString()
                        self.nonce = nonce
                        request.requestedScopes = [.email, .fullName]
                        request.nonce = sha256(nonce)
                    } onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            loginWithFirebase(authorization)
                        case .failure(let error):
                            showError(error.localizedDescription)
                        }
                    }
                    .frame(height: 50)
                    .cornerRadius(25)
                    
                    // Google Login
                    Button(action: {
                        GoogleSignInMehod()
                    }) {
                        HStack {
                            Image("googleIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            Text("Continue with Google")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 1)
                
                
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
            }
            .background(Color.white)
            .alert(errorMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
            .overlay {
                if isLoading {
                    LoadingScreen()
                }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                MainView()
                    .navigationBarBackButtonHidden(true)
            }
        
                   .toolbar {
                       ToolbarItem(placement: .navigationBarLeading) {
                           Button(action: {
                               presentationMode.wrappedValue.dismiss()
                           }) {
                               HStack {
                                   Image(systemName: "chevron.left") // Back icon
                                   Text("Back")
                               }
                               .foregroundColor(.blue)
                           }
                       }
                   }
               }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            checkBiometricAvailability()
        }
    }
    
    
    private func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometryType = context.biometryType
            isBiometricAvailable = true
            print("Biometry Type: \(context.biometryType == .faceID ? "Face ID" : "Touch ID")")
        } else {
            print("Biometric not available: \(error?.localizedDescription ?? "Unknown error")")
            isBiometricAvailable = false
        }
    }
    
    private func authenticateWithBiometric() {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            showError(error?.localizedDescription ?? "Biometric authentication not available")
            return
        }
        
        isLoading = true
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: "Log in to your account") { success, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if success {
                    if let savedEmail = UserDefaults.standard.string(forKey: "savedEmail"),
                       let savedPassword = UserDefaults.standard.string(forKey: "savedPassword") {
                        self.email = savedEmail
                        self.password = savedPassword
                        handleEmailPasswordSignIn()
                    } else {
                        showError("No saved credentials. Please sign in with email first.")
                    }
                } else if let error = error {
                    showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func handleEmailPasswordSignIn() {
        guard !email.isEmpty, !password.isEmpty else {
            showError("Please fill in all fields")
            return
        }
        
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                showError(error.localizedDescription)
                return
            }
            
            
            UserDefaults.standard.set(email, forKey: "savedEmail")
            UserDefaults.standard.set(password, forKey: "savedPassword")
            
            logStatus = true
            isLoading = false
            navigateToHome = true
        }
        
    }
    func showErrorx(_ message: String) {
        showError("Incorrect Email or Password!")
        showAlert.toggle()
        isLoading = false
    }
    func GoogleSignInMehod() {
        isLoading = true
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            showError("Try Again!")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            showError("Try Again!")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                showError(error.localizedDescription)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                showError("Try Again!")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    showError(error.localizedDescription)
                    return
                }
                
                logStatus = true
                isLoading = false
                navigateToHome = true
            }
        }
    }
    
    func showError(_ message: String) {
        errorMessage = message
        showAlert.toggle()
        isLoading = false
    }
    
    func loginWithFirebase(_ authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            isLoading = true
            guard let nonce = nonce else {
                showError("Cannot process your request.")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                showError("Cannot process your request.")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                showError("Cannot process your request.")
                return
            }
            
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    showError(error.localizedDescription)
                    return
                }
                
                logStatus = true
                isLoading = false
                navigateToHome = true
            }
        }
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


extension SignInSignUpView {
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
}


struct SignInSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignInSignUpView()
    }
}

struct SocialButtonStyle: ButtonStyle {
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
