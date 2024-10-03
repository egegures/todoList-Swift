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
    
    private let firebaseManager = FirebaseManager.shared
    
    private init() {
        
        // Uncomment this to reset UserDefaults
        //
        //        UserDefaults.standard.dictionaryRepresentation().keys.forEach { key in
        //            UserDefaults.standard.removeObject(forKey: key)
        //        }
        
        // Local load
        //        if let data = UserDefaults.standard.data(forKey: "SavedData") {
        //            if let decoded = try? JSONDecoder().decode([Category].self, from: data) {
        //                categories = decoded
        //            }
        //        }
        //        if categories.count == 0 {
        //            addCategory()
        //        }
        
        loadCloud() {
            if self.categories.count == 0 {
                self.addCategory()
            }
        }
        print("CategoryManager initialized")
    }
    
    func addCategory() {
        let newCategory = Category()
        categories.append(newCategory)
        firebaseManager.saveCategory(newCategory)
    }
    
    func deleteCategory(_ id: UUID) {
        if let index = categories.firstIndex(where: { $0.id == id }) {
            firebaseManager.deleteCategory(categories[index])
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
            firebaseManager.saveCategory(category)
        }
    }
    
    func findCategoryFromID(categoryID: UUID) -> Category? {
        if let cat = categories.first(where: { $0.id == categoryID }) {
            return cat
        }
        return nil
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
            firebaseManager.saveCategory(cat)
        }
    }
    
    func sortCategoriesByFavourite() {
        categories.sort(by: {$0.isFavourite && !$1.isFavourite})
    }
    
    func saveLocal() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "SavedData")
        }
    }
    
    func loadCloud(completion: @escaping () -> Void) {
        firebaseManager.fetchCategories { [weak self] fetchedCategories in
            DispatchQueue.main.async {
                self?.categories = fetchedCategories
                completion()
            }
        }
    }
    
    func clearCategories() {
        categories.removeAll()
    }
    
}

