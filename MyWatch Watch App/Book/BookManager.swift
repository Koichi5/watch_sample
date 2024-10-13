//
//  BookManager.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/09.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
class BookManager: ObservableObject {
    private let modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()
    
    @Published var books: [Book] = []
    
    init() {
        print("watch init fired")
        self.modelContext = DataController.shared.container.mainContext
        fetchBooks()
        setupSyncSubscription()
    }
    
    func fetchBooks() {
        let descriptor = FetchDescriptor<Book>(
            sortBy: [SortDescriptor(\.lastModified, order: .reverse)]
        )
        do {
            books = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching books: \(error.localizedDescription)")
        }
    }
    
    func addBook(_ book: Book) {
        modelContext.insert(book)
        saveBooks()
    }
    
    func updateBook(_ book: Book) {
        book.lastModified = Date()
        saveBooks()
    }
    
    func deleteBook(_ book: Book) {
        modelContext.delete(book)
        saveBooks()
    }
    
    private func saveBooks() {
        do {
            try modelContext.save()
            fetchBooks()
            DataController.shared.syncData()
        } catch {
            print("Error saving books: \(error.localizedDescription)")
        }
    }
    
    private func setupSyncSubscription() {
        DataController.shared.$lastSyncDate
            .dropFirst()
            .sink { [weak self] _ in
                self?.fetchBooks()
            }
            .store(in: &cancellables)
    }
}
