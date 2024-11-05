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
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State private var showDeleteConfirmation = false
    @FocusState private var isFocusedOnTitle: Bool
    @FocusState private var isFocusedOnCalendar: Bool
    
    @State private var isPresentingNotification: Bool = false
    var body: some View {
        VStack(alignment: .leading) {
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
                
                Image(systemName: showDeleteConfirmation ? "checkmark.circle.fill" : "circle")
                    .frame(width: 16, height: 16)
                    .onTapGesture {
                        if showDeleteConfirmation {
                            task.deleteTask()
                            categoryManager.checkEmptyTask(task.categoryID)
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
                TextField("New task", text: $task.name)
                    .background(Color.gray.opacity(0.2))
                    .focused($isFocusedOnTitle)
                    .onChange(of: isFocusedOnTitle) {
                        if isFocusedOnTitle == false {
                            task.setDate()
                            task.simplifyTitle()
                            categoryManager.sortTasksByDate(task.categoryID)
                            categoryManager.checkEmptyTask(task.categoryID)
                            // categoryManager.saveLocal()
                        }
                        else {
                            task.expandTitle()
                        }
                    }
            }
            
            HStack(spacing: 40) {
                Image(systemName: (task.isNotificationSet ? "bell.fill" : "bell"))
                    .foregroundColor(task.isNotificationSet ? .orange : .black)
                    .onTapGesture {
                        withAnimation {
                            isPresentingNotification.toggle()
                        }
                    }
                CalendarTimeView(task: task)
                    .focused($isFocusedOnCalendar)
                    .onChange(of: isFocusedOnCalendar, {
                        if isFocusedOnCalendar == false {
                            categoryManager.sortTasksByDate(task.categoryID)
                            // categoryManager.saveLocal()
                        }
                    })
                
            }
        }
        .sheet(isPresented: $isPresentingNotification) {
            NotificationView(task: task, showMenu: $isPresentingNotification)
                .environmentObject(notificationManager)
                .environmentObject(categoryManager)
        }
        
        //        if showDeleteConfirmation {
        //            Text("Click again to confirm")
        //                .foregroundColor(.red)
        //                .transition(.opacity)
        //                .padding(.top, 8)
        //        }
    }
}

#Preview {
    return TaskView(task: Task(categoryID: UUID()))
        .environmentObject( CategoryManager.shared)
        .environmentObject(NotificationManager.shared)
}
