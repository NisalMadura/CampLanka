//
//  NotificationManager.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-18.
//

import UIKit
import UserNotifications

class CampingAppViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
        requestNotificationPermission()
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notifications permission: \(error)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }

    func scheduleTripReminder(for date: Date, tripName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Trip Reminder!"
        content.body = "Don't forget your trip to \(tripName) tomorrow!"
        content.sound = .default

        let timeInterval = date.timeIntervalSinceNow - (24 * 60 * 60)

        guard timeInterval > 0 else {
            print("Trip date has already passed!")
            return
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

        let request = UNNotificationRequest(identifier: "TripReminder-\(tripName)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling trip reminder: \(error)")
            } else {
                print("Trip reminder scheduled for \(tripName).")
            }
        }
    }

    func scheduleGroupMessageReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Group Chat Reminder"
        content.body = "You have unread messages in your camping group chat."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)

        let request = UNNotificationRequest(identifier: "GroupMessageReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling group message reminder: \(error)")
            } else {
                print("Group message reminder scheduled.")
            }
        }
    }

    func scheduleNearbyServiceNotification(serviceName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Nearby Service Alert"
        content.body = "\(serviceName) is available near your location!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1800, repeats: false)

        let request = UNNotificationRequest(identifier: "NearbyService-\(serviceName)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling nearby service notification: \(error)")
            } else {
                print("\(serviceName) notification scheduled.")
            }
        }
    }

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
