// LoginView.swift
// TodoList
//
// Created by Ege Gures on 2024-08-21.
//

import SwiftUI
import Combine

struct LoginView: View {
    
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var categoryManager: CategoryManager
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @Binding var showLoginView: Bool
    
    @State private var signUpSuccesful: Bool = false
    @State private var signInSuccessful: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("X")
                    .onTapGesture {
                        showLoginView = false
                    }
            }
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
            
            if signInSuccessful {
                Text("Sign in successful, redirecting...")
                    .foregroundStyle(Color.green)
            }
            if signUpSuccesful {
                Text("Sign in successful, redirecting...")
                    .foregroundStyle(Color.green)
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .padding()
        .frame(width: 250)
    }
    
    private func signUp() {
        firebaseManager.signUp(email: email, password: password) { result in
            switch result {
            case .success(_):
                // Handle successful sign up
                print("Sign up successful")
                signUpSuccesful.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    showLoginView = false
                    signUpSuccesful.toggle()
                })
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
                // Handle successful sign in
                print("Sign in successful")
                signInSuccessful.toggle()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    showLoginView = false
                    signInSuccessful.toggle()
                })
                
                categoryManager.loadCloud() {}
            case .failure(let error):
                self.alertMessage = error.localizedDescription
                self.showingAlert = true
            }
        }
    }
}

#Preview {
    @Previewable
    @State var bool: Bool = true
    return LoginView(showLoginView: $bool)
        .environmentObject(FirebaseManager.shared)
        .environmentObject(CategoryManager.shared)
}
