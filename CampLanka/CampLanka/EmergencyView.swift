//
//  EmergencyView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-10-28.
//

import SwiftUI

struct EmergencyType: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}

struct EmergencyView: View {
    @State private var isSOSPressed = false
    @State private var sosTimer: Timer?
    @State private var pressCount = 0
    
    let emergencyTypes = [
        EmergencyType(name: "Medical", icon: "cross.case.fill", color: .green.opacity(0.2)),
        EmergencyType(name: "Fire", icon: "flame", color: .red.opacity(0.2)),
        EmergencyType(name: "Natural disaster", icon: "tornado", color: .mint.opacity(0.2)),
        EmergencyType(name: "Accident", icon: "car.fill", color: .purple.opacity(0.2)),
        EmergencyType(name: "Violence", icon: "exclamationmark.triangle", color: .pink.opacity(0.2)),
        EmergencyType(name: "Rescue", icon: "person.fill.questionmark", color: .yellow.opacity(0.2))
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Navigation Bar
            HStack {
                Button(action: {
                    // Handle back action
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                        Text("Back")
                            .foregroundColor(.blue)
                    }
                }
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        // Handle camera action
                    }) {
                        Image(systemName: "camera")
                            .foregroundColor(.black)
                    }
                    
                    Button(action: {
                        // Handle notification action
                    }) {
                        Image(systemName: "bell")
                            .foregroundColor(.black)
                    }
                }
            }
            .padding()
            
            // Header Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Are you in an emergency?")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Press the SOS button, your live location will be \n shared with the nearest help centre and your emergency contacts")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal)
            
            // SOS Button
            Button(action: {
                handleSOSPress()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .shadow(radius: 5)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .fill(Color.red)
                        .frame(width: 160, height: 160)
                    
                    VStack {
                        Text("SOS")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Text("Press 3 for second")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.vertical, 30)
            
            // Emergency Types Section
            Text("What's your emergency?")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                ForEach(emergencyTypes) { type in
                    EmergencyTypeButton(type: type)
                }
            }
            .padding()
            
            Spacer()
            
            // Custom Tab Bar placeholder
            CustomTabBar()
        }
    }
    
    private func handleSOSPress() {
        pressCount += 1
        
        if pressCount == 1 {
            sosTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                pressCount = 0
                sosTimer?.invalidate()
            }
        }
        
        if pressCount >= 3 {
            isSOSPressed = true
            // Trigger emergency actions here
            triggerEmergency()
        }
    }
    
    private func triggerEmergency() {
        // Implement emergency actions:
        // 1. Get current location
        // 2. Send alert to emergency contacts
        // 3. Contact nearest help center
    }
}

struct EmergencyTypeButton: View {
    let type: EmergencyType
    
    var body: some View {
        VStack {
            Circle()
                .fill(type.color)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: type.icon)
                        .foregroundColor(type.color == .yellow.opacity(0.2) ? .orange : .black)
                )
            
            Text(type.name)
                .font(.caption)
                .foregroundColor(.black)
        }
    }
}

struct EmergencyView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyView()
    }
}
