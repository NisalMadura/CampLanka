//
//  EmergencyCallingView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-10-28.
//

import SwiftUI

struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let angle: Double
    let distance: CGFloat
}

struct EmergencyCallingView: View {
    @State private var isAnimating = false
    @State private var counter = 1
    @Environment(\.dismiss) var dismiss
    
    let contacts = [
        Contact(name: "Emy jackson", angle: 45, distance: 100),
        Contact(name: "Sister", angle: 135, distance: 100),
        Contact(name: "Dad", angle: 225, distance: 100),
        Contact(name: "Albert", angle: 315, distance: 100)
    ]
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.orange.opacity(0.2),
                    Color.orange.opacity(0.1),
                    Color.white
                ]),
                center: .center,
                startRadius: 20,
                endRadius: 300
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                            Text("Back")
                                .foregroundColor(.blue)
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color.white.opacity(0.5))
                
                
                Text("Calling emergency...")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 30)
                
                Text("Please stand by, we are currently requesting\nfor help. Your emergency contacts and nearby\nrescue services would see your call for help")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.top, 8)
                
                Spacer()
                
                
                ZStack {
                    
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            .frame(width: isAnimating ? 300 : 100, height: isAnimating ? 300 : 100)
                            .scaleEffect(isAnimating ? 1.5 : 0.5)
                            .opacity(isAnimating ? 0 : 1)
                            .animation(
                                Animation.easeInOut(duration: 2)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(index) * 0.5),
                                value: isAnimating
                            )
                    }
                    
                    
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text("\(String(format: "%02d", counter))")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 10)
                    
                    
                    ForEach(contacts) { contact in
                        ContactAvatar(contact: contact)
                            .offset(
                                x: cos(contact.angle * .pi / 180) * contact.distance,
                                y: sin(contact.angle * .pi / 180) * contact.distance
                            )
                    }
                }
                .padding(.bottom, 100)
                
                Spacer()
                
                
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray)
                    .frame(width: 40, height: 5)
                    .padding(.bottom, 8)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            isAnimating = true
        }
        .onReceive(timer) { _ in
            counter += 1
        }
    }
}

struct ContactAvatar: View {
    let contact: Contact
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(Color.white)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 5)
            
            Text(contact.name)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}


struct EmergencyCallingView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyCallingView()
    }
}
