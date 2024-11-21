//
//  NotificationPermissionView.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-10-27.
//

import SwiftUI

struct NotificationPermissionView: View {
    @State private var notificationExample = NotificationExample(
        title: "Dinner's Ready!",
        message: "Your recipe for Grilled Salmon and Veggies is ready to go.Time to start cooking!"
    )
    
    @State private var features = [
        "New daily meal reminders",
        "Motivational messages",
        "Personalized guideline"
    ]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Spacer()
                    Button("Skip") {
                        dismiss()
                    }
                    .foregroundColor((Color(red: 0/255, green: 84/255, blue: 64/255)))
                }
                
                Text("Do you want to turn on notifications?")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top, 8)
            }
            
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                    Text("now")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Spacer()
                }
                
                Text(notificationExample.title)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(notificationExample.message)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .frame(width: 20, alignment: .center)
                        
                        Text(feature)
                            .font(.system(size: 16))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 24)
                }
            }
            
            Spacer()
            
            
            Button(action: {
                
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("Notifications enabled")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
                dismiss()
            }) {
                Text("Enable")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background((Color(red: 0/255, green: 84/255, blue: 64/255)))
                    .cornerRadius(25)
            }
        }
        .padding(24)
    }
}

struct NotificationExample {
    let title: String
    let message: String
}

struct NotificationPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPermissionView()
    }
}
