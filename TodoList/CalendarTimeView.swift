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

    }
}

#Preview {
    CalendarTimeView(task: Task(categoryID: UUID()))
}
