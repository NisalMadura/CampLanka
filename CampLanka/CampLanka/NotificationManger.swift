//
//  NotificationManger.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-20.
//


import UserNotifications
import UIKit


class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    
    func scheduleCampingReminder(title: String, body: String, date: Date, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
    
    
    func removeNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}


class NotificationManagementViewController: UIViewController {
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "NotificationCell")
        return table
    }()
    
    private var notifications: [UNNotificationRequest] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadNotifications()
    }
    
    private func setupUI() {
        title = "Notifications"
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(addNotificationTapped)
        )
    }
    
    private func loadNotifications() {
        NotificationManager.shared.getPendingNotifications { [weak self] notifications in
            self?.notifications = notifications
            self?.tableView.reloadData()
        }
    }
    
    @objc private func addNotificationTapped() {
        let alert = UIAlertController(title: "New Camping Reminder", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Title"
        }
        alert.addTextField { textField in
            textField.placeholder = "Message"
        }
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        alert.view.addSubview(datePicker)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let title = alert.textFields?[0].text,
                  let message = alert.textFields?[1].text,
                  !title.isEmpty, !message.isEmpty else { return }
            
            let identifier = UUID().uuidString
            NotificationManager.shared.scheduleCampingReminder(
                title: title,
                body: message,
                date: datePicker.date,
                identifier: identifier
            )
            
            self?.loadNotifications()
        })
        
        present(alert, animated: true)
    }
}


extension NotificationManagementViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath)
        let notification = notifications[indexPath.row]
        
        cell.textLabel?.text = notification.content.title
        cell.detailTextLabel?.text = notification.content.body
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let notification = notifications[indexPath.row]
            NotificationManager.shared.removeNotification(withIdentifier: notification.identifier)
            notifications.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
