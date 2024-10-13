//
//  RecordManager.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/09.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
class RecordManager: ObservableObject {
    private let modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()
    
    @Published var records: [Record] = []
    
    init() {
        self.modelContext = DataController.shared.container.mainContext
        fetchRecords()
        setupSyncSubscription()
    }
    
    func fetchRecords() {
        let descriptor = FetchDescriptor<Record>(
            sortBy: [SortDescriptor(\.lastModified, order: .reverse)]
        )
        do {
            records = try modelContext.fetch(descriptor)
            print("records: \(records)")
        } catch {
            print("Error fetching records: \(error.localizedDescription)")
        }
    }
    
    func addRecord(book: Book, seconds: Int) {
        let createdAt = Date()
        let record = Record(book: book, seconds: seconds, createdAt: createdAt)
        modelContext.insert(record)
        saveRecords()
    }

    
    func updateRecord(_ record: Record) {
        record.lastModified = Date()
        saveRecords()
    }
    
    func deleteRecord(_ record: Record) {
        modelContext.delete(record)
        saveRecords()
    }
    
    private func saveRecords() {
        do {
            try modelContext.save()
            fetchRecords()
            DataController.shared.syncData()
        } catch {
            print("Error saving records: \(error)")
            if let nserror = error as NSError? {
                print("Error domain: \(nserror.domain)")
                print("Error code: \(nserror.code)")
                print("Error user info: \(nserror.userInfo)")
            }
        }
    }
    
    private func setupSyncSubscription() {
        DataController.shared.$lastSyncDate
            .dropFirst()
            .sink { [weak self] _ in
                self?.fetchRecords()
            }
            .store(in: &cancellables)
    }
}
