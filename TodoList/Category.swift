//
//  Category.swift
//  TodoList
//
//  Created by Ege Gures on 2024-08-05.
//

import Foundation

class Category: Identifiable, ObservableObject, Encodable, Decodable {
    
    @Published var id: UUID
    @Published var name: String
    @Published var tasks: [Task] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case tasks
    }
    
    init() {
        self.id = UUID()
        self.name = "New Category"
        self.tasks.append(Task(categoryID: self.id))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(tasks, forKey: .tasks)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        tasks = try container.decode([Task].self, forKey: .tasks)
    }
    
    func deleteCategory() {
        CategoryManager.shared.deleteCategory(self.id)
    }
    
    deinit {
        deleteCategory()
    }
}
