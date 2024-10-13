//
//  DataController.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/13.
//

// DataController.swift (iOS)

import SwiftData
import Foundation

class DataController: NSObject, ObservableObject {
    static let shared = DataController()

    let container: ModelContainer
    @Published var lastSyncDate: Date?

    private override init() {
        do {
            print("iOS DataController initialized")
            let schema = Schema([Book.self, Record.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    func syncData() {
        Task {
            do {
                let context = await container.mainContext
                let books = try await context.fetch(FetchDescriptor<Book>())
                let records = try await context.fetch(FetchDescriptor<Record>())

                // RecordをRecordDTOにマッピング
                let recordDTOs = records.map { RecordDTO(record: $0) }

                let syncData = SyncData(books: books, records: recordDTOs)
                let encodedData = try JSONEncoder().encode(syncData)

                WatchConnectivityManager.shared.sendData(encodedData)
                self.lastSyncDate = Date()
            } catch {
                print("Error syncing data: \(error.localizedDescription)")
            }
        }
    }

    func processReceivedData(_ data: Data) {
        Task {
            do {
                let syncData = try JSONDecoder().decode(SyncData.self, from: data)
                let context = await container.mainContext

                // まずBookを処理
                for book in syncData.books {
                    if let existingBook = try await context.fetch(FetchDescriptor<Book>(predicate: #Predicate { $0.id == book.id })).first {
                        existingBook.title = book.title
                        existingBook.publisher = book.publisher
                        existingBook.imageUrl = book.imageUrl
                        existingBook.lastModified = book.lastModified
                    } else {
                        context.insert(book)
                    }
                }

                // 次にRecordを処理
                for recordDTO in syncData.records {
                    let record = try await recordDTO.toRecord(context: context)
                    if let existingRecord = try await context.fetch(FetchDescriptor<Record>(predicate: #Predicate { $0.id == record.id })).first {
                        existingRecord.seconds = record.seconds
                        existingRecord.lastModified = record.lastModified
                        existingRecord.book = record.book
                    } else {
                        context.insert(record)
                    }
                }

                try context.save()
                self.lastSyncDate = Date()
            } catch {
                print("Error processing received data: \(error)")
            }
        }
    }
}

struct SyncData: Codable {
    let books: [Book]
    let records: [RecordDTO] // [RecordDTO] に変更
}


struct RecordDTO: Codable {
    let id: UUID
    let bookID: UUID
    let seconds: Int
    let createdAt: Date
    let lastModified: Date

    init(record: Record) {
        self.id = record.id
        self.bookID = record.book.id
        self.seconds = record.seconds
        self.createdAt = record.createdAt
        self.lastModified = record.lastModified
    }

    func toRecord(context: ModelContext) async throws -> Record {
        if let book = try await context.fetch(FetchDescriptor<Book>(predicate: #Predicate { $0.id == bookID })).first {
            return Record(id: id, book: book, seconds: seconds, createdAt: createdAt, lastModified: lastModified)
        } else {
            throw NSError(domain: "DataController", code: 404, userInfo: [NSLocalizedDescriptionKey: "Book not found for Record"])
        }
    }
}
