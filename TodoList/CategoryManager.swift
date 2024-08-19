//
//  CategoryManager.swift
//  TodoList
//
//  Created by Ege Gures on 2024-08-05.
//

import Foundation

class CategoryManager: ObservableObject {
    static let shared = CategoryManager()
    
    @Published var categories: [Category] = []
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: "SavedData") {
            if let decoded = try? JSONDecoder().decode([Category].self, from: data) {
                categories = decoded
            }
        }
        // addCategory()
    }
    
    func addCategory() {
        let newCategory = Category()
        categories.append(newCategory)
    }
    
    func deleteCategory(_ id: UUID) {
        if let index = categories.firstIndex(where: { $0.id == id }) {
            categories.remove(at: index)
        }
        if categories.count == 0 {
            addCategory()
        }
    }
    
    func deleteTask(_ task: Task) {
        if let category = categories.first(where: { $0.id == task.categoryID}) {
            category.tasks.removeAll(where: {$0.id == task.id})
        }
    }
    
    func checkEmptyTask(_ id: UUID) {
        if let category = categories.first(where: { $0.id == id }) {
            for task in category.tasks {
                if task.name.isEmpty {
                    return
                }
            }
            category.tasks.append(Task(categoryID: category.id))
        }
    }
    
    func findNameFromID(_ id: UUID) -> String {
        if let cat = categories.first(where: { $0.id == id }) {
            return cat.name
        }
        return "name not found"
    }
    
    func sortTasksByDate(_ catID: UUID) {
        if let cat = categories.first(where: { $0.id == catID}) {
            cat.tasks.sort(by: { $0.dueDate < $1.dueDate })
            
            for task in cat.tasks {                                    // Delete These
                if task.name == "" {                                   // Lines
                    cat.tasks.removeAll(where: {$0.id == task.id})     // To Prevent
                    break                                              // New Task
                }                                                      // From
            }                                                          // Going
            cat.tasks.append(Task(categoryID: catID))                  // To Bottom
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(categories) {
                UserDefaults.standard.set(encoded, forKey: "SavedData")
            }
    }
    
    

}

