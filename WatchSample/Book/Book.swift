//
//  Book.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/09.
//

import Foundation
import SwiftData

@Model
final class Book {
    var id: UUID
    var title: String
    var publisher: String
    var imageUrl: String
    var lastModified: Date
    
    init(id: UUID = UUID(), title: String, publisher: String, imageUrl: String, lastModified: Date = Date()) {
        self.id = id
        self.title = title
        self.publisher = publisher
        self.imageUrl = imageUrl
        self.lastModified = lastModified
    }
}

extension Book: Codable {
    enum CodingKeys: String, CodingKey {
        case id, title, publisher, imageUrl, lastModified
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(publisher, forKey: .publisher)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(lastModified, forKey: .lastModified)
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let title = try container.decode(String.self, forKey: .title)
        let publisher = try container.decode(String.self, forKey: .publisher)
        let imageUrl = try container.decode(String.self, forKey: .imageUrl)
        let lastModified = try container.decode(Date.self, forKey: .lastModified)
        self.init(id: id, title: title, publisher: publisher, imageUrl: imageUrl, lastModified: lastModified)
    }
}
