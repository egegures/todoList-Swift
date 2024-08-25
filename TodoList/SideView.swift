// SideMenu.swift
// TodoList
//
// Created by Ege Gures on 2024-08-21.
//

import SwiftUI

struct SideView: View {
    @Binding var isOpen: Bool
    
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var categoryManager: CategoryManager
    
    @State private var showingLoginView = false
    var body: some View {
        ZStack {
            if isOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isOpen.toggle()
                        }
                    }
                
                HStack {
                    VStack(alignment: .leading) {
                        if firebaseManager.isLoggedIn() {
                            Text("Hello, " + firebaseManager.getUsername()!)
                                .padding(5)
                            
                            Button("Sign Out") {
                                firebaseManager.signOut()
                                categoryManager.clearCategories()
                            }
                            .padding(5)
                        } else {
                            Button("Sign In") {
                                // Navigate to Sign In view
                                showingLoginView.toggle()
                            }
                            .padding(5)
                        }
                        
                        
                        Button("Task History") {
                            // Navigate to Task History view
                        }
                        .padding(5)
                        
                        Spacer()
                    }
                    .transition(.move(edge: .leading))
                }
                .sheet(isPresented: $showingLoginView) {
                    LoginView(showLoginView: $showingLoginView)
                                }
            }
        }
        .frame(width: isOpen ? 120 : 0)
    }
}


#Preview {
    @State var isOpen = true
    return SideView(isOpen: $isOpen)
        .environmentObject(FirebaseManager.shared)
        .environmentObject(CategoryManager.shared)
}
