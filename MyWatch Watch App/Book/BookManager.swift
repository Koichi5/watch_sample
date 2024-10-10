//
//  BookManager.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/09.
//

import SwiftData
import WatchConnectivity

@MainActor
class BookManager: NSObject, ObservableObject {
    let modelContainer: ModelContainer
    let modelContext: ModelContext
    
    @Published var books: [Book] = []
    
    override init() {
        do {
            modelContainer = try ModelContainer(for: Book.self)
            modelContext = modelContainer.mainContext
        } catch {
            fatalError("Failed to create ModelContainer fot Book: \(error.localizedDescription)")
        }
        
        super.init()
        
        fetchBooks()
        setupWatchConnectivity()
    }
    
    func fetchBooks() {
        let descriptor = FetchDescriptor<Book>(
            sortBy: [SortDescriptor(\.lastModified)]        )
        do {
            books = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching books: \(error.localizedDescription)")
        }
    }
    
    func addBook(_ book: Book) {
        modelContext.insert(book)
        saveBooks()
        sendBooksToWatch()
    }
    
    func updateBook(_ book: Book) {
        book.lastModified = Date()
        saveBooks()
        sendBooksToWatch()
    }
    
    func deleteBook(_ book: Book) {
        modelContext.delete(book)
        saveBooks()
        sendBooksToWatch()
    }
    
    private func saveBooks() {
        do {
            try modelContext.save()
            fetchBooks()
        } catch {
            print("Error saving books: \(error.localizedDescription)")
        }
    }
    
    // WatchConnectivity
    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    private func sendBooksToWatch() {
        guard WCSession.default.isReachable else {
            print("Watch is not reachable")
            return
        }
        
        do {
            let encodedBooks = try JSONEncoder().encode(books)
            WCSession.default.sendMessage(["books": encodedBooks], replyHandler: { reply in
                print("Message sent successfully to watch. Reply: \(reply)")
            }) { error in
                print("Error sending books to watch: \(error.localizedDescription)")
            }
        } catch {
            print("Error encoding books: \(error.localizedDescription)")
        }
    }
}

extension BookManager: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any],
        replyHandler: @escaping ([String : Any]) -> Void
    ) {
        guard let encodedBooks = message["books"] as? Data else {
            print("Received message does not contain books data")
            replyHandler(["status": "error", "message": "Invalid data reveived"])
            return
        }
        
        do {
            let decodedBooks = try JSONDecoder().decode([Book].self, from: encodedBooks)
            DispatchQueue.main.async {
                self.updateLocalBooks(with: decodedBooks)
                replyHandler(["status": "success"])
            }
        } catch {
            print("Error decoding books: \(error.localizedDescription)")
            replyHandler(["status": "error", "message": "Falied to decode books"])
        }
    }
    
    private func updateLocalBooks(with receivedBooks: [Book]) {
        for book in books {
            modelContext.delete(book)
        }
        books = receivedBooks
        
        for book in books {
            modelContext.insert(book)
        }
        
        saveBooks()
    }
}
