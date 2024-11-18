//
//  NotificationSettingsViewController.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-18.
//

import UIKit
import UserNotifications

class NotificationSettingsViewController: UIViewController {

    let tripReminderToggle = UISwitch()
    let timePicker = UIDatePicker()
    let saveButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        
        view.backgroundColor = .white
        setupUI()

        
        loadSettings()
    }

    private func setupUI() {
        
        let tripReminderLabel = UILabel()
        tripReminderLabel.text = "Enable Trip Reminders"
        tripReminderLabel.font = UIFont.systemFont(ofSize: 18)

        tripReminderToggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)

        
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels

        
        saveButton.setTitle("Save Settings", for: .normal)
        saveButton.addTarget(self, action: #selector(saveSettings), for: .touchUpInside)

        
        let stackView = UIStackView(arrangedSubviews: [tripReminderLabel, tripReminderToggle, timePicker, saveButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc private func toggleChanged() {
        print("Trip Reminder Toggle: \(tripReminderToggle.isOn)")
    }

    @objc private func saveSettings() {
        // Save user preferences
        UserDefaults.standard.set(tripReminderToggle.isOn, forKey: "TripReminderEnabled")
        UserDefaults.standard.set(timePicker.date, forKey: "NotificationTime")

        // Schedule notification if enabled
        if tripReminderToggle.isOn {
            scheduleNotification()
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }

        let alert = UIAlertController(title: "Saved", message: "Your settings have been saved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func loadSettings() {
        let isReminderEnabled = UserDefaults.standard.bool(forKey: "TripReminderEnabled")
        tripReminderToggle.isOn = isReminderEnabled

        if let notificationTime = UserDefaults.standard.object(forKey: "NotificationTime") as? Date {
            timePicker.date = notificationTime
        }
    }

    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Trip Reminder"
        content.body = "Don't forget your camping trip!"
        content.sound = .default

        let selectedTime = timePicker.date
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedTime)
        let minute = calendar.component(.minute, from: selectedTime)

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "TripReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    }
}
