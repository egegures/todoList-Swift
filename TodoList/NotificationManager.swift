//
//  NotificationManager.swift
//  TodoList
//
//  Created by Ege Gures on 2024-08-21.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    
    static let shared = NotificationManager()
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission denied: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification(task: Task, date: Date) -> Bool {
        
        if date < Date() {
            return false
        }
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        
        let taskName: String
        let components = task.name.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
        
        if components.count == 2 {
            taskName = components[0]
        } else {
            taskName = task.name
        }
        content.body = taskName + " due " + dateFormatter.string(from: task.dueDate)
        
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
        print("Set notification for \(task.id.uuidString)")
        return true
    }
    
    func removeNotification(task: Task) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let requestExists = requests.contains(where: { $0.identifier == task.id.uuidString })
            print("Notification exists: \(requestExists)")
            if requestExists {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
                print("Notification removed for task: \(task.id.uuidString)")
            } else {
                print("No notification found for task: \(task.id.uuidString)")
            }
        }
    }


}
