//
//  TaskView.swift
//  TodoList
//
//  Created by Ege Gures on 2024-08-05.
//

import SwiftUI

struct TaskView: View {
    @ObservedObject var task: Task
    @EnvironmentObject var categoryManager: CategoryManager
    
    @State private var showDeleteConfirmation = false
    @FocusState private var isFocusedOnTitle: Bool
    @FocusState private var isFocusedOnCalendar: Bool
    
    var body: some View {
        HStack {
            //            ZStack {
            //                Image(systemName: task.completed ? "circle.fill" : "circle")
            //                    .resizable()
            //                    .frame(width: 16, height: 16)
            //                    .padding()
            //                Rectangle()
            //                    .fill(Color.clear)
            //                    .frame(width: 30, height: 30)
            //                    .contentShape(Circle())
            //                    .onTapGesture {
            //                        task.completed.toggle()
            //                    }
            //            }
            Image(systemName: "trash")
                .resizable()
                .frame(width: 16, height: 16)
                .onTapGesture {
                    if showDeleteConfirmation {
                        task.deleteTask()
                        categoryManager.checkEmptyTask(task.categoryID)
                        categoryManager.save()
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
            TextField("New task", text: $task.name)
                .background(Color.gray.opacity(0.2))
                .focused($isFocusedOnTitle)
                .onChange(of: isFocusedOnTitle) {
                    if isFocusedOnTitle == false {
                        task.setDate()
                        task.simplifyTitle()
                        categoryManager.sortTasksByDate(task.categoryID)
                        categoryManager.checkEmptyTask(task.categoryID)
                        categoryManager.save()
                    }
                    else {
                        task.expandTitle()
                    }
                }
            CalendarTimeView(task: task)
                .focused($isFocusedOnCalendar)
                .onChange(of: isFocusedOnCalendar, {
                    if isFocusedOnCalendar == false {
                        categoryManager.sortTasksByDate(task.categoryID)
                        categoryManager.save()
                    }
                })
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
    let categoryManager = CategoryManager.shared
    let category = Category()
    let task = Task(categoryID: category.id)
    return TaskView(task: task)
        .environmentObject(categoryManager)
}

