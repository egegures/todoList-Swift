// FirebaseManager.swift
// TodoList
//
// Created by Ege Gures on 2024-08-21.
//

import Foundation
import Firebase
import FirebaseAuth
import Combine

class FirebaseManager: ObservableObject {

    static let shared = FirebaseManager()
    
    @Published var user: User?
    @Published var errorMessage: String?

    private init() {
        FirebaseApp.configure()
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
            }
        }
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
            }
        } catch let error {
            self.handleAuthError(error)
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
