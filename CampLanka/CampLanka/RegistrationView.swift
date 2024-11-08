import SwiftUI
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import FirebaseDatabase

struct RegistrationView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isTermsAccepted: Bool = false
    @State private var showPassword: Bool = false
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var showErrorAlert = false
        @State private var showSuccessAlert = false
        @State private var errorMessage = ""

    
    // Reference to Firebase Database
    private let dbRef = Database.database().reference()
    
    // Dark green color used throughout the app
    private let campGreen = Color(red: 0/255, green: 84/255, blue: 64/255)
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                // Logo
                Image("camplogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .padding(.top, 50)
                
                // Title
                Text("Sign Up")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                
                // Form Fields
                VStack(spacing: 12) {
                    // Name Field
                    CustomTextField(
                        text: $name,
                        placeholder: "Enter your name",
                        clearButton: true
                    )
                    
                    // Email Field
                    CustomTextField(
                        text: $email,
                        placeholder: "Enter your email address",
                        clearButton: true
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    
                    // Password Field
                    CustomTextField(
                        text: $password,
                        placeholder: "Enter password",
                        isSecure: !showPassword,
                        clearButton: true,
                        showPasswordToggle: true,
                        isPasswordField: true,
                        togglePasswordVisibility: {
                            showPassword.toggle()
                        }
                    )
                }
                .padding(.top, 20)
                // Divider
                                    HStack {
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(.gray)
                                        Text("or")
                                            .foregroundColor(.gray)
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(.gray)
                                    }
                // Continue with Apple
                                   Button(action: {}) {
                                       HStack {
                                           Image("apple")
                                               .resizable()
                                               .aspectRatio(contentMode: .fit)
                                               .frame(width: 20, height: 20)
                                           Text("Continue with Apple")
                                               .foregroundColor(.white)
                                               .bold()
                                       }
                                       .frame(maxWidth: .infinity)
                                       .padding()
                                       .background(Color.black)
                                       .cornerRadius(25)
                                   }
                                   .padding(.top, 10)
                                   
                                   // Continue with Google
                                   Button(action: {
                                       signUpWithGoogle()
                                   }) {
                                       HStack {
                                           Image("googleIcon")
                                               .resizable()
                                               .frame(width: 20, height: 20)
                                           Text("Continue with Google")
                                       }
                                       .font(.headline)
                                       .foregroundColor(.black)
                                       .frame(maxWidth: .infinity)
                                       .padding()
                                       .background(Color.white)
                                       .overlay(
                                           RoundedRectangle(cornerRadius: 50)
                                               .stroke(Color.gray, lineWidth: 1)
                                       )
                                       .padding(.horizontal, 0)
                                   }
                                   
                // Terms Checkbox
                HStack(alignment: .center, spacing: 8) {
                    Button(action: {
                        isTermsAccepted.toggle()
                    }) {
                        Image(systemName: isTermsAccepted ? "checkmark.square.fill" : "square")
                            .foregroundColor(isTermsAccepted ? campGreen : .gray)
                            .font(.system(size: 20))
                    }
                    
                    Text("You agree to our ")
                        .foregroundColor(.black)
                        .font(.system(size: 14))
                    + Text("Terms of Service")
                        .foregroundColor(.black)
                        .font(.system(size: 14))
                   
                }
                .padding(.top, 10)
                
                // Continue Button
                Button(action: {
                    registerUser()
                }) {
                    Text(isLoading ? "Processing..." : "Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isFormValid ? campGreen : campGreen.opacity(0.5))
                        .cornerRadius(25)
                }
                .disabled(!isFormValid || isLoading)
                .padding(.top, 14)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Registration"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if alertMessage.contains("successful") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
            
            if isLoading {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && isTermsAccepted
    }
    
    private func registerUser() {
        isLoading = true
        
        // Validate email format
        guard isValidEmail(email) else {
            alertMessage = "Please enter a valid email address"
            showAlert = true
            isLoading = false
            return
        }
        
        // Validate password strength
        guard password.count >= 6 else {
            alertMessage = "Password must be at least 6 characters long"
            showAlert = true
            isLoading = false
            return
        }
        
        // Create user in Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
                isLoading = false
                return
            }
            
            guard let user = authResult?.user else {
                alertMessage = "Registration failed. Please try again."
                showAlert = true
                isLoading = false
                return
            }
            
            // Create user data dictionary
            let userData: [String: Any] = [
                "name": name,
                "email": email,
                "createdAt": ServerValue.timestamp(),
                "lastUpdated": ServerValue.timestamp()
            ]
            
            // Save user data to Firebase Realtime Database
            dbRef.child("users").child(user.uid).setValue(userData) { error, _ in
                isLoading = false
                
                if let error = error {
                    alertMessage = "Failed to save user data: \(error.localizedDescription)"
                    showAlert = true
                } else {
                    alertMessage = "Registration successful!"
                    showAlert = true
                }
            }
        }
    }
    func signUpWithGoogle() {
            isLoading = true
            
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                errorMessage = "Google Sign In configuration error"
                showErrorAlert = true
                return
            }
            
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                errorMessage = "Cannot find root view controller"
                showErrorAlert = true
                return
            }
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showErrorAlert = true
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    self.errorMessage = "Cannot get user data from Google."
                    self.showErrorAlert = true
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        self.showErrorAlert = true
                        return
                    }
                    
                    guard let user = authResult?.user else {
                        self.errorMessage = "Could not retrieve user data."
                        self.showErrorAlert = true
                        return
                    }
                }
            }
        }
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
}

// CustomTextField Component remains unchanged
struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    var isSecure: Bool = false
    var clearButton: Bool = false
    var showPasswordToggle: Bool = false
    var isPasswordField: Bool = false
    var togglePasswordVisibility: (() -> Void)? = nil
    
    private let campGreen = Color(red: 0/255, green: 84/255, blue: 64/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .trailing) {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 17))
                } else {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 17))
                }
                
                HStack(spacing: 16) {
                    if !text.isEmpty && clearButton {
                        Button(action: {
                            text = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                        }
                    }
                    
                    if showPasswordToggle && isPasswordField {
                        Button(action: {
                            togglePasswordVisibility?()
                        }) {
                            Image(systemName: isSecure ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
