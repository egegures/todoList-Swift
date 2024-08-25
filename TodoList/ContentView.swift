//  ContentView.swift
//  TodoList
//
//  Created by Ege Gures on 2024-08-05.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var categoryManager: CategoryManager
    @EnvironmentObject private var notificationManager: NotificationManager
    
    @State private var sideViewOpen: Bool = false
    
    var body: some View {
        HStack {
            SideView(isOpen: $sideViewOpen)
                .environmentObject(firebaseManager)
                .environmentObject(categoryManager)
            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            sideViewOpen.toggle()
                        }
                    }, label: {
                        Image(systemName: "list.dash")
                            .imageScale(.large)
                    })
                    Spacer()
                    Button(action: {
                        categoryManager.addCategory()
                        // categoryManager.saveLocal()
                    }, label: {
                        Text("New category")
                    })
                }
                List {
                    ForEach(categoryManager.categories) { category in
                        CategoryView(category: category)
                    }
                }
            }
            .environmentObject(categoryManager)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(FirebaseManager.shared)
        .environmentObject(CategoryManager.shared)
        .environmentObject(NotificationManager.shared)
}
