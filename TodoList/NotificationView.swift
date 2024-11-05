//
//  NotificationView.swift
//  TodoList
//
//  Created by Ege Gures on 2024-08-21.
//

import SwiftUI

struct NotificationView: View {
    
    @ObservedObject var task: Task
    @EnvironmentObject var ncShared: NotificationManager
    @EnvironmentObject var categoryManager: CategoryManager
    
    @Binding var showMenu: Bool
    
    var body: some View {
//        if showMenu {
            VStack {
                Text("When would you like to be notified? ")
                    .fontWeight(.bold)
                DatePicker("", selection: $task.notificationDate)
                    .labelsHidden()
                    .datePickerStyle(GraphicalDatePickerStyle())
                HStack {
                    Button(action: { //Unset button
                        task.isNotificationSet = false
                        ncShared.removeNotification(task: task)
                        // categoryManager.saveLocal()
                        withAnimation {
                            showMenu.toggle()
                        }
                    }, label: {
                        Text("Unset")
                    })
                    
                    Button(action: { //Set button
                        task.isNotificationSet = ncShared.scheduleNotification(task: task, date: task.notificationDate)
                        // categoryManager.saveLocal()
                        withAnimation {
                            showMenu.toggle()
                        }
                    }, label: {
                        Text("Set")
                    })
                }
//            }
        }
    }
}

#Preview {
    @Previewable
    @State var showMenu: Bool = true
    NotificationView(task: Task(categoryID: UUID()), showMenu: $showMenu)
        .environmentObject(NotificationManager.shared)
        .environmentObject(CategoryManager.shared)
}
