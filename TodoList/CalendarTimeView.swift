//
//  CalendarTimeView.swift
//  TodoList
//
//  Created by Ege Gures on 2024-08-18.
//

import SwiftUI

struct CalendarTimeView: View {
    @ObservedObject var task: Task
    
    var body: some View {
        DatePicker("", selection: $task.dueDate)
            .labelsHidden()
            .padding(5)
            .frame(width: 80, height: 30)
            .font(.system(size: 12))
    }
}

#Preview {
    CalendarTimeView(task: Task(categoryID: UUID()))
}
