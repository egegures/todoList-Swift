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
    
    @State private var showMenu: Bool = false
    
    var body: some View {
        Image(systemName: (task.isNotificationSet ? "bell.fill" : "bell"))
            .onTapGesture {
                withAnimation {
                    showMenu.toggle()
                    if !task.isNotificationSet {
                        task.notificationDate = task.dueDate
                    }
                }
            }
        if showMenu {
            VStack {
                Text("Set notification")
                DatePicker("", selection: $task.notificationDate)
                    .labelsHidden()
                HStack {
                    Button(action: { //Unset button
                        task.isNotificationSet = false
                        ncShared.removeNotification(task: task)
                        CategoryManager.shared.save()
                        withAnimation {
                            showMenu.toggle()
                        }
                    }, label: {
                        Text("Unset")
                    })
                    
                    Button(action: { //Set button
                        task.isNotificationSet = ncShared.scheduleNotification(task: task, date: task.notificationDate)
                        CategoryManager.shared.save()
                        withAnimation {
                            showMenu.toggle()
                        }
                    }, label: {
                        Text("Set")
                    })
                }
            }
        }
    }
}

#Preview {
    let shared = NotificationManager.shared
    return NotificationView(task: Task(categoryID: UUID()))
        .environmentObject(shared)
}
