//
//  TodoListApp.swift
//  TodoList
//
//  Created by Ege Gures on 2024-08-05.
//

import SwiftUI
import Firebase
import FirebaseFirestore

@main
struct TodoListApp: App {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @StateObject private var categoryManager = CategoryManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    init() {
        FirebaseApp.configure()
        Firestore.firestore()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(firebaseManager)
                .environmentObject(categoryManager)
                .environmentObject(notificationManager)
                .onAppear {
                    NotificationManager.shared.requestAuthorization()
                    categoryManager.loadCloud {}
                }
        }
    }
}
