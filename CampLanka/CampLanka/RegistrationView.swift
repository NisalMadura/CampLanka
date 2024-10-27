//
//  RegistrationView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-10-27.
//

import SwiftUI

struct RegistrationView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isTermsAccepted: Bool = false
    @State private var showPassword: Bool = false
    
    // Dark green color used throughout the app
    private let campGreen = Color(red: 0/255, green: 84/255, blue: 64/255)
    
    var body: some View {
        VStack(spacing: 24) {
            // Logo
            Image("camplogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding(.top, 60)
            
            // Title
            Text("Enjoy stress-free\ncamping")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.top, 20)
            
            // Form Fields
            VStack(spacing: 20) {
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
                
                // Password Field
                CustomTextField(
                    text: $password,
                    placeholder: "Enter password",
                    isSecure: !showPassword,
                    clearButton: true,
                    showPasswordToggle: true,
                    isPasswordField: true
                )
            }
            .padding(.top, 20)
            
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
                + Text(" and acknowledge our ")
                    .foregroundColor(.black)
                    .font(.system(size: 14))
                + Text("Privacy Policy")
                    .foregroundColor(.black)
                    .font(.system(size: 14))
            }
            .padding(.top, 20)
            
            // Continue Button
            Button(action: {
                // Handle registration
            }) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0/255, green: 84/255, blue: 64/255))
                    .cornerRadius(25)
            }
            .disabled(!isFormValid)
            .padding(.top, 24)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && isTermsAccepted
    }
}

// Custom TextField Component
struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    var isSecure: Bool = false
    var clearButton: Bool = false
    var showPasswordToggle: Bool = false
    var isPasswordField: Bool = false
    
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
                           // isSecure.toggle()
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
