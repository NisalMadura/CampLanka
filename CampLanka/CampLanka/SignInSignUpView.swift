//
//  SignInSignUpView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-10-27.
//

import SwiftUI
import Firebase

struct SignInSignUpView: View {
  
    var body: some View {
        VStack(spacing: 24) {
            // Logo
            Image("camplogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding(.top, 60)
            
            // Title
            Text("Sign in or create a\nfree profile")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.top, 20)
            
            // Description
            Text("Join CampLanka to discover amazing campsites, plan trips, and collaborate with friends.Start your adventure today!")
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(.gray))
                .padding(.horizontal, 32)
            
            
            // Social Login Buttons
            VStack(spacing: 16) {
                // Apple Login Button
                Button(action: {
                    // Handle Apple login
                }) {
                    HStack {
                        Image(systemName: "apple.logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        Text("Continue with Apple")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.black)
                    .cornerRadius(25)
                }
                
                // Facebook Login Button
                Button(action: {
                    // Handle Facebook login
                }) {
                    HStack {
                        Image(systemName: "f.square.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        Text("Continue with Facebook")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 24/255, green: 119/255, blue: 242/255))
                    .cornerRadius(25)
                }
                
                // Google Login Button
                Button(action: {
                    // Handle Google login
                }) {
                    HStack {
                        Image("googleIcon") // Add Google icon to assets
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
                
                // Email Login Button
                Button(action: {
                    // Handle Email login
                }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        Text("Continue with Email")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0/255, green: 84/255, blue: 64/255)) // Dark Green
                    .cornerRadius(25)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            
           // Spacer()
            
            // Terms and Privacy
            VStack(spacing: 4) {
                Text("You are agree to our \n Terms of Use")
                    .foregroundColor(.black)
                    .font(.system(size: 14))
                + Text(" and ")
                    .foregroundColor(.black)
                    .font(.system(size: 14))
                + Text("Privacy Policy")
                    .foregroundColor(.black)
                    .font(.system(size: 14))
            }
            .multilineTextAlignment(.center)
            .padding(.bottom, 32)
        }
        .background(Color.white)
    }
}

// Preview
struct SignInSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignInSignUpView()
    }
}

// Custom button style
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
