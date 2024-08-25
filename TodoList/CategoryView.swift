//
//  CategoryView.swift
//  TodoList
//
//  Created by Ege Gures on 2024-08-05.
//

import SwiftUI

struct CategoryView: View {
    @ObservedObject var category: Category
    @EnvironmentObject var categoryManager: CategoryManager
    @State private var showDeleteConfirmation: Bool = false
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "trash")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .onTapGesture {
                        if showDeleteConfirmation {
                            category.deleteCategory()
                            // categoryManager.saveLocal()
                        } else {
                            withAnimation {
                                showDeleteConfirmation = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showDeleteConfirmation = false
                                }
                            }
                        }
                    }
                
                TextField("New Category", text: $category.name)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                
                Image(systemName: (category.isFavourite ? "star.fill" : "star"))
                    .foregroundStyle(Color.yellow)
                    .onTapGesture {
                        category.isFavourite.toggle()
                        categoryManager.sortCategoriesByFavourite()
                        // categoryManager.saveLocal()
                    }
            }
            
            ForEach(category.tasks) { task in
                TaskView(task: task)
                    .environmentObject(categoryManager)
            }
        }
        if showDeleteConfirmation {
            Text("Click again to confirm")
                .foregroundColor(.red)
                .transition(.opacity)
                .padding(.top, 8)
        }
        
    }
}

#Preview {
    CategoryView(category: Category())
        .environmentObject(CategoryManager.shared)
}

