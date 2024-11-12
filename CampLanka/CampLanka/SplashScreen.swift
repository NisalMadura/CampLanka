// CampLankaApp.swift
import SwiftUI
import CoreData


struct SpalshScreen: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            // Your main app view here
            SignInView()
        } else {
            SplashScreenView()
                .onAppear {
                    // Simulate splash screen delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
        }
    }
}

// Create a new file: SplashScreenView.swift
import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color(red: 0, green: 0.33, blue: 0.25) // Dark green color
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Tent/Tipi Logo
                Image(systemName: "tent.fill") 
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)
                
                // Camplanka Text
                Text("CAMPLANKA")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                
            }
        }
    }
}

// Preview Providers
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
