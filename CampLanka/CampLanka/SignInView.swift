//
//  ContentView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-10-27.
//

import SwiftUI

struct SignInView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Logo from assets
                Image("camplogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .padding(.top, 60)
                
                // Title
                Text("Sign in or create a\nfree profile")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                
                // Description
                Text("CampLanka makes camping easy with personalized campsite suggestions, trip planning, and group collaboration. Sign up now and start exploring!")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)
                
                VStack(spacing: 16) {
                    // Sign In Button
                    Button(action: {
                        // Handle sign in
                    }) {
                        Text("Sign In")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundColor(.white)
                            .background(Color(red: 0/255, green: 84/255, blue: 64/255))
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 24)
                    
                    // Create Profile Button
                    Button(action: {
                        // Handle create profile
                    }) {
                        Text("Create Free Profile")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundColor(.white)
                            .background(Color(red: 0/255, green: 84/255, blue: 64/255))
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 24)
                
                Spacer()
                
                // I'll do it later button
                Button(action: {
                    // Handle skip
                }) {
                    Text("I'll do it later")
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                }
                .padding(.bottom, 32)
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
