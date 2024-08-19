//
//  ContentView.swift
//  TodoList
//
//  Created by Ege Gures on 2024-08-05.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var categoryManager = CategoryManager.shared
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    categoryManager.addCategory()
                    categoryManager.save()
                }, label: {
                    Text("New cat")
                })
            }
            List {
                ForEach(categoryManager.categories) { category in
                    CategoryView(category: category)
                }
            }
            .padding()
            
        }
        .environmentObject(categoryManager)
    }
}

#Preview {
    ContentView()
        .environmentObject(CategoryManager.shared)
}
