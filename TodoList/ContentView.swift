//  ContentView.swift
//  TodoList
//
//  Created by Ege Gures on 2024-08-05.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var categoryManager = CategoryManager.shared
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    @State private var sideViewOpen: Bool = false
    
    var body: some View {
        HStack {
            SideView(isOpen: $sideViewOpen)
                .environmentObject(firebaseManager)
            VStack {
                HStack {
                    Button(action: {
                        sideViewOpen.toggle()
                    }, label: {
                        Image(systemName: "list.dash")
                            .imageScale(.large)
                    })
                    Spacer()
                    Button(action: {
                        categoryManager.addCategory()
                        categoryManager.save()
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
}
