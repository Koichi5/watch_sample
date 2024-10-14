//
//  DataController.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/14.
//

import XCTest
import SwiftData
@testable import WatchSample

class DataControllerTests: XCTestCase {
    var dataController: DataController!
    var mockConnectivityManager: MockWatchConnectivityManager!
    var container: ModelContainer!

    override func setUp() async throws {
        try await super.setUp()

        // インメモリの ModelContainer をセットアップ
        let schema = Schema([Book.self, Record.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [modelConfiguration])

        // モックの WatchConnectivityManager を初期化
        mockConnectivityManager = MockWatchConnectivityManager()

        // DataController をモックと共に初期化
        dataController = DataController(container: container, connectivityManager: mockConnectivityManager)
    }

    override func tearDown() {
        dataController = nil
        mockConnectivityManager = nil
        container = nil
        super.tearDown()
    }

    @MainActor func testSyncData() throws {
        // Arrange: テストデータを作成
        let context = container.mainContext

        let testBook = Book(title: "Test Book", publisher: "Test Publisher", imageUrl: "http://example.com/image.jpg")
        context.insert(testBook)

        let testRecord = Record(book: testBook, seconds: 120, createdAt: Date(), lastModified: Date())
        context.insert(testRecord)

        try context.save()

        // Act: syncData() を呼び出す
         dataController.syncData()

        // Assert: データが送信されたことを確認
        XCTAssertNotNil(mockConnectivityManager.sentData, "データが送信されていません")

        // 送信されたデータをデコード
        let decoder = JSONDecoder()
        let syncData = try decoder.decode(SyncData.self, from: mockConnectivityManager.sentData!)

        // データの内容を検証
        XCTAssertEqual(syncData.books.count, 1)
        XCTAssertEqual(syncData.books.first?.id, testBook.id)
        XCTAssertEqual(syncData.records.count, 1)
        XCTAssertEqual(syncData.records.first?.id, testRecord.id)
    }

    func testProcessReceivedData() async throws {
        // Arrange: 受信するテストデータを作成
        let testBook = Book(id: UUID(), title: "Received Book", publisher: "Received Publisher", imageUrl: "http://example.com/received_image.jpg", lastModified: Date())
        let testRecordDTO = RecordDTO(id: UUID(), bookID: testBook.id, seconds: 300, createdAt: Date(), lastModified: Date())

        let syncData = SyncData(books: [testBook], records: [testRecordDTO])

        let encoder = JSONEncoder()
        let data = try encoder.encode(syncData)

        // Act: processReceivedData(_:) を呼び出す
        await dataController.processReceivedData(data)

        // Assert: データがコンテキストに保存されたことを確認
        let context = await container.mainContext

        // Book の検証
        let fetchedBooks = try await context.fetch(FetchDescriptor<Book>())
        XCTAssertEqual(fetchedBooks.count, 1)
        XCTAssertEqual(fetchedBooks.first?.id, testBook.id)
        XCTAssertEqual(fetchedBooks.first?.title, testBook.title)
        XCTAssertEqual(fetchedBooks.first?.publisher, testBook.publisher)
        XCTAssertEqual(fetchedBooks.first?.imageUrl, testBook.imageUrl)
        XCTAssertEqual(fetchedBooks.first?.lastModified, testBook.lastModified)

        // Record の検証
        let fetchedRecords = try await context.fetch(FetchDescriptor<Record>())
        XCTAssertEqual(fetchedRecords.count, 1)
        XCTAssertEqual(fetchedRecords.first?.id, testRecordDTO.id)
        XCTAssertEqual(fetchedRecords.first?.seconds, testRecordDTO.seconds)
        XCTAssertEqual(fetchedRecords.first?.createdAt, testRecordDTO.createdAt)
        XCTAssertEqual(fetchedRecords.first?.book.id, testBook.id)
    }
}
