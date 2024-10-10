//
//  Todo.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/08.
//

import Foundation
import SwiftData

@Model
final class Todo {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var lastModified: Date
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, lastModified: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.lastModified = lastModified
    }
}

// Codableに準拠させるための拡張
extension Todo: Codable {
    enum CodingKeys: String, CodingKey {
        case id, title, isCompleted, lastModified
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(lastModified, forKey: .lastModified)
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let title = try container.decode(String.self, forKey: .title)
        let isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        let lastModified = try container.decode(Date.self, forKey: .lastModified)
        self.init(id: id, title: title, isCompleted: isCompleted, lastModified: lastModified)
    }
}
