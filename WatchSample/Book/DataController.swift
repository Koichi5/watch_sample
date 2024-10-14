//
//  DataController.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/13.
//

import SwiftData
import Foundation

@MainActor
class DataController: NSObject, ObservableObject {
    static let shared = DataController()
    
    let container: ModelContainer
    @Published var lastSyncDate: Date?
    private lazy var connectivityManager: WatchConnectivityManager = WatchConnectivityManager.shared
    
    private override init() {
        do {
            print("iOS DataController initialized")
            let schema = Schema([Book.self, Record.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            self.container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
        super.init()
    }
    
    // テスト用の初期化子
    init(container: ModelContainer, connectivityManager: WatchConnectivityManager) {
        self.container = container
        super.init()
        self.connectivityManager = connectivityManager
    }
    
    @MainActor func syncData() {
        do {
            let context = container.mainContext
            let books = try context.fetch(FetchDescriptor<Book>())
            let records = try context.fetch(FetchDescriptor<Record>())
            
            let recordDTOs = records.map { RecordDTO(record: $0) }
            
            let syncData = SyncData(books: books, records: recordDTOs)
            let encodedData = try JSONEncoder().encode(syncData)
            
            connectivityManager.sendData(encodedData)
            self.lastSyncDate = Date()
        } catch {
            print("Error syncing data: \(error.localizedDescription)")
        }
    }

    func processReceivedData(_ data: Data) async {
        do {
            let syncData = try JSONDecoder().decode(SyncData.self, from: data)
            let context = await container.mainContext

            // Book の処理
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

            // Record の処理
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
