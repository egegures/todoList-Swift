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
    @State var isSet: Bool = false
    @State var setDate: Date = Date()
    
    var body: some View {
        Image(systemName: (isSet ? "bell.fill" : "bell"))
            .onTapGesture {
                withAnimation {
                    showMenu.toggle()
                    if !isSet {
                        setDate = task.dueDate
                    }
                }
            }
        if showMenu {
            VStack {
                Text("Set notification")
                DatePicker("", selection: $setDate)
                    .labelsHidden()
                HStack {
                    Button(action: { //Unset button
                        isSet = false
                        ncShared.removeNotification(task: task)
                        withAnimation {
                            showMenu.toggle()
                        }
                    }, label: {
                        Text("Unset")
                    })
                    
                    Button(action: { //Set button
                        isSet = ncShared.scheduleNotification(task: task, date: setDate)
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
