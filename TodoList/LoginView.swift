// LoginView.swift
// TodoList
//
// Created by Ege Gures on 2024-08-21.
//

import SwiftUI
import Combine

struct LoginView: View {
    
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""

    @Binding var showLoginView: Bool
    
    //TODO: Add text below buttons as "sign in/up successful", add x button top right that toggles showLoginView
    var body: some View {
        VStack {
            Text("Email:")
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
            
            Text("Password:")
            SecureField("Password", text: $password)
                .textContentType(.password)
            
            HStack {
                Button(action: {
                    signUp()
                }, label: {
                    Text("Sign up")
                })
                .padding()
                
                Button(action: {
                    signIn()
                }, label: {
                    Text("Sign in")
                })
                .padding()
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .padding()
    }
    
    private func signUp() {
        firebaseManager.signUp(email: email, password: password) { result in
            switch result {
            case .success(_):
                // Handle successful sign up (e.g., navigate to another view)
                print("Sign up successful")
            case .failure(let error):
                self.alertMessage = error.localizedDescription
                self.showingAlert = true
            }
        }
    }
    
    private func signIn() {
        firebaseManager.signIn(email: email, password: password) { result in
            switch result {
            case .success(_):
                // Handle successful sign in (e.g., navigate to another view)
                print("Sign in successful")
            case .failure(let error):
                self.alertMessage = error.localizedDescription
                self.showingAlert = true
            }
        }
    }
}

#Preview {
    @State var bool: Bool = true
    return LoginView(showLoginView: $bool)
        .environmentObject(FirebaseManager.shared)
}
