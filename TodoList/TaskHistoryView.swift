//
//  TaskHistoryView.swift
//  TodoList
//
//  Created by Ege Gures on 2024-08-27.
//

import SwiftUI

struct TaskHistoryView: View {
    
    var tasks = Task.taskHistory
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
            }
            ForEach(tasks) { task in
                
                Text("Task \(task.name) due \(dateFormatter(task.dueDate))")
            }
            Spacer()
        }
    }
    
    private func dateFormatter(_ date: Date) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        return dateFormatter.string(from: date)
        
    }
}

#Preview {
    TaskHistoryView()
}
