//
//  RecordDTO.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/14.
//

import Foundation
import SwiftData

struct RecordDTO: Codable {
    let id: UUID
    let bookID: UUID
    let seconds: Int
    let createdAt: Date
    let lastModified: Date

    // 既存の初期化子
    init(record: Record) {
        self.id = record.id
        self.bookID = record.book.id
        self.seconds = record.seconds
        self.createdAt = record.createdAt
        self.lastModified = record.lastModified
    }

    init(id: UUID, bookID: UUID, seconds: Int, createdAt: Date, lastModified: Date) {
        self.id = id
        self.bookID = bookID
        self.seconds = seconds
        self.createdAt = createdAt
        self.lastModified = lastModified
    }

    func toRecord(context: ModelContext) async throws -> Record {
        // ここで id に一致する Book を取得して、 Record につっこむ
        if let book = try await context.fetch(FetchDescriptor<Book>(predicate: #Predicate { $0.id == bookID })).first {
            return Record(id: id, book: book, seconds: seconds, createdAt: createdAt, lastModified: lastModified)
        } else {
            throw NSError(domain: "DataController", code: 404, userInfo: [NSLocalizedDescriptionKey: "Book not found for Record"])
        }
    }
}
