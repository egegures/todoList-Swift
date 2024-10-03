// FirebaseManager.swift
// TodoList
//
// Created by Ege Gures on 2024-08-21.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine

class FirebaseManager: ObservableObject {
    
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    @Published var user: User?
    @Published var errorMessage: String?
    
    private init() {
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
            }
        }
        print("Firebase initialized")
    }
    
    
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.handleAuthError(error)
                completion(.failure(error))
            } else if let user = result?.user {
                DispatchQueue.main.async {
                    self.user = user
                    completion(.success(user))
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.handleAuthError(error)
                completion(.failure(error))
            } else if let user = result?.user {
                DispatchQueue.main.async {
                    self.user = user
                    completion(.success(user))
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.user = nil
                CategoryManager.shared.clearCategories()
            }
        } catch let error {
            self.handleAuthError(error)
        }
    }
    
    func isLoggedIn() -> Bool {
        return !(Auth.auth().currentUser == nil)
        
    }
    
    func getUsername() -> String? {
        // TODO: Get actual name instead of email
        
        guard let email = Auth.auth().currentUser?.email else {
            return nil
        }
        let components = email.split(separator: "@")
        return String(components[0])
    }
    
    func saveCategory(_ category: Category) {
        guard let user = Auth.auth().currentUser else { return }
        let userDocRef = db.collection("users").document(user.uid)
        let categoryDocRef = userDocRef.collection("categories").document(category.id.uuidString)
        
        do {
            let encodedCategory = try Firestore.Encoder().encode(category)
            categoryDocRef.setData(encodedCategory) { error in
                if let error = error {
                    print("Error saving category: \(error.localizedDescription)")
                } else {
                    print("Category saved successfully!")
                }
            }
        } catch {
            print("Error encoding category: \(error.localizedDescription)")
        }
    }
    
    func saveTaskHistory() {
        guard let user = Auth.auth().currentUser else { return }
        let userDocRef = db.collection("users").document(user.uid)
        let taskHistoryRef = userDocRef.collection("taskHistory")
        
        do {
            for task in Task.taskHistory {
                let taskDocRef = taskHistoryRef.document(task.id.uuidString)
                let encodedTask = try Firestore.Encoder().encode(task)
                taskDocRef.setData(encodedTask) { error in
                    if let error = error {
                        print("Error saving task to history: \(error.localizedDescription)")
                    } else {
                        print("Task saved to history successfully!")
                    }
                }
            }
        } catch {
            print("Error encoding task: \(error.localizedDescription)")
        }
    }
    
    func fetchCategories(completion: @escaping ([Category]) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion([])
            return
        }
        
        let userDocRef = db.collection("users").document(user.uid)
        
        userDocRef.collection("categories").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
                completion([])
            } else {
                var categories: [Category] = []
                snapshot?.documents.forEach { document in
                    do {
                        let category = try document.data(as: Category.self)
                        categories.append(category)
                    } catch {
                        print("Error decoding category: \(error.localizedDescription)")
                    }
                }
                completion(categories)
            }
        }
    }
    
    func fetchTaskHistory(completion: @escaping () -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion()
            return
        }
        
        let userDocRef = db.collection("users").document(user.uid)
        
        userDocRef.collection("taskHistory").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching task history: \(error.localizedDescription)")
                completion()
            } else {
                var tasks: [Task] = []
                snapshot?.documents.forEach { document in
                    do {
                        let task = try document.data(as: Task.self)
                        tasks.append(task)
                    } catch {
                        print("Error decoding task: \(error.localizedDescription)")
                    }
                }
                Task.taskHistory = tasks
                completion()
            }
        }
    }

    
    func deleteCategory(_ category: Category) {
        guard let user = Auth.auth().currentUser else { return }
        let userDocRef = db.collection("users").document(user.uid)
        let categoryDocRef = userDocRef.collection("categories").document(category.id.uuidString)
        
        categoryDocRef.delete { error in
            if let error = error {
                print("Error deleting category: \(error.localizedDescription)")
            } else {
                print("Category deleted successfully!")
            }
        }
    }
    
    func deleteTask(task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])))
            return
        }
        
        let taskRef = db.collection("users").document(user.uid)
            .collection("categories").document(task.categoryID.uuidString)
            .collection("tasks").document(task.id.uuidString)
        
        taskRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    
    private func handleAuthError(_ error: Error) {
        if let authError = error as NSError? {
            switch AuthErrorCode(rawValue: authError.code) {
            case .emailAlreadyInUse:
                errorMessage = "The email address is already in use by another account."
            case .wrongPassword:
                errorMessage = "The password is invalid or the user does not have a password."
            case .invalidEmail:
                errorMessage = "The email address is badly formatted."
            case .userNotFound:
                errorMessage = "There is no user record corresponding to this identifier."
            default:
                errorMessage = "An unexpected error occurred. Please try again."
            }
        } else {
            errorMessage = "An unexpected error occurred. Please try again."
        }
    }
}
