//
//  Task.swift
//  TodoList
//
//  Created by Ege Gures on 2024-08-05.
//

import Foundation

class Task: Identifiable, ObservableObject, Encodable, Decodable {
    
    @Published var id: UUID
    @Published var name: String
    @Published var dueDate: Date
    @Published var completed: Bool
    @Published var categoryID: UUID
    @Published var isNotificationSet: Bool
    @Published var notificationDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case dueDate
        case completed
        case categoryID
        case isNotificationSet
        case notificationDate
    }
    
    init(categoryID: UUID) {
        self.id = UUID()
        self.name = ""
        self.completed = false
        self.dueDate = Task.endOfDayDate()
        self.categoryID = categoryID
        self.isNotificationSet = false
        self.notificationDate = Task.endOfDayDate()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(completed, forKey: .completed)
        try container.encode(categoryID, forKey: .categoryID)
        try container.encode(isNotificationSet, forKey: .isNotificationSet)
        try container.encode(notificationDate, forKey: .notificationDate)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        dueDate = try container.decode(Date.self, forKey: .dueDate)
        completed = try container.decode(Bool.self, forKey: .completed)
        categoryID = try container.decode(UUID.self, forKey: .categoryID)
        isNotificationSet = try container.decode(Bool.self, forKey: .isNotificationSet)
        notificationDate = try container.decode(Date.self, forKey: .notificationDate)
    }
    
    
    func deleteTask() {
        CategoryManager.shared.deleteTask(self)
    }
    
    private static func endOfDayDate() -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        
        let endOfDayComponents = DateComponents(
            year: components.year,
            month: components.month,
            day: components.day,
            hour: 23,
            minute: 59,
            second: 59
        )
        
        return calendar.date(from: endOfDayComponents) ?? now
    }
    
    func extractDate() -> Date? {
        
        let components = self.name.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
        
        guard components.count == 2 else { return nil }
        
        let dateString = components[1]
        
        let formats = [
            "dd.MM.yy HH:mm",  // With day, month, year, hour, and minute
            "dd.MM HH:mm",     // With day, month, hour and minute
            "dd.MM.yy",        // With day, month, year
            "dd.MM"            // With day and month only
        ]
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        for format in formats {
            dateFormatter.dateFormat = format
            
            if let date = dateFormatter.date(from: dateString) {
                if dateFormatter.dateFormat == "dd.MM" {
                    let calendar = Calendar.current
                    var dateComponents = calendar.dateComponents([.day, .month], from: date)
                    dateComponents.year = calendar.component(.year, from: Date())
                    dateComponents.hour = 23
                    dateComponents.minute = 59
                    return calendar.date(from: dateComponents)
                } else if dateFormatter.dateFormat == "dd.MM.yy" {
                    let calendar = Calendar.current
                    var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                    dateComponents.hour = 23
                    dateComponents.minute = 59
                    return calendar.date(from: dateComponents)
                } else if dateFormatter.dateFormat == "dd.MM HH:mm" {
                    let calendar = Calendar.current
                    var dateComponents = calendar.dateComponents([.day, .month, .hour, .minute], from: date)
                    dateComponents.year = calendar.component(.year, from: Date())
                    return calendar.date(from: dateComponents)
                }
                return date
            }
        }
        
        return nil
    }
    
    func setDate() {
        if let userSetDate = extractDate() {
            dueDate = userSetDate
        }
    }
    
    func simplifyTitle() {
        let components = self.name.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
        self.name = (components.count == 2 ? components[0] : self.name)
    }
    
    func expandTitle() {
        
        if self.name == "" {
            return
        }
        if !self.name.contains("|") {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy HH:mm"
            self.name = self.name + " | " + dateFormatter.string(from: self.dueDate)
        }
    }
    
    deinit {
        deleteTask()
    }
}

