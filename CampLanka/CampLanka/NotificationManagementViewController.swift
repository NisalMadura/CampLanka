//
//  NotificationManagementViewController.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-20.
//

import Foundation
import SwiftUI

class YourMainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        
        let testButton = UIButton(frame: CGRect(x: 20, y: 100, width: 200, height: 50))
        testButton.setTitle("Create Test Notification", for: .normal)
        testButton.backgroundColor = .systemBlue
        testButton.addTarget(self, action: #selector(createTestNotification), for: .touchUpInside)
        view.addSubview(testButton)
    }
    
    @objc private func createTestNotification() {
        
        let futureDate = Date().addingTimeInterval(10)
        
        NotificationManager.shared.scheduleCampingReminder(
            title: "Test Camping Reminder",
            body: "Your camping trip starts in 3 days! Don't forget your gear!",
            date: futureDate,
            identifier: UUID().uuidString
        )
        
        
        let alert = UIAlertController(
            title: "Notification Scheduled",
            message: "You'll receive the notification in 10 seconds",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
