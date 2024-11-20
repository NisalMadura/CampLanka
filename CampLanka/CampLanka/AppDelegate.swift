//
//  AppDelegate.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-05.
//

import UIKit
import Firebase
import GoogleSignIn
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NotificationManager.shared.requestAuthorization { granted in
            if granted {
                print("Notification permission granted")
                
                
                self.scheduleTestNotifications()
            }
        }
        FirebaseApp.configure()
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    private func scheduleTestNotifications() {
        
        
        
        NotificationManager.shared.scheduleCampingReminder(
            title: "Camping Reminder",
            body: "Time to check your camping gear!",
            date: Date().addingTimeInterval(60),
            identifier: UUID().uuidString
            
            
        )
    }
    
}

