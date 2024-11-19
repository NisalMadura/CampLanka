

import SwiftUI

struct ContentView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            
            SignInView()
        } else {
            SplashScreenView()
                .onAppear {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
        }
    }
}

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color(red: 0, green: 0.33, blue: 0.25)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
            
                Image("mainlogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)
                
                
                Text("CAMPLANKA")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                
            }
        }
    }
}


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
