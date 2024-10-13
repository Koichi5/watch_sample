//
//  Record.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/09.
//

import Foundation
import SwiftData

@Model
final class Record {
    var id: UUID
    @Relationship(deleteRule: .cascade)
    var book: Book
    var seconds: Int
    var lastModified: Date
    
    init(id: UUID = UUID(), book: Book, seconds: Int, lastModified: Date = Date()) {
        self.id = id
        self.book = book
        self.seconds = seconds
        self.lastModified = lastModified
    }
}

extension Record: Codable {
    enum CodingKeys: String, CodingKey {
        case id, book, seconds, lastModified
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(book, forKey: .book)
        try container.encode(seconds, forKey: .seconds)
        try container.encode(lastModified, forKey: .lastModified)
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let book = try container.decode(Book.self, forKey: .book)
        let seconds = try container.decode(Int.self, forKey: .seconds)
        let lastModified = try container.decode(Date.self, forKey: .lastModified)
        self.init(id: id, book: book, seconds: seconds, lastModified: lastModified)
    }
}
