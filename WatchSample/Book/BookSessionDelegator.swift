//
//  MaterialSessionDelegator.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/09.
//

import Foundation
import WatchConnectivity

class BookSessionDelegator: NSObject, WCSessionDelegate, ObservableObject {
    @Published var books: [Book] = []

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let type = message["type"] as? String {
                switch type {
                case "addBook":
                    if let bookData = message["book"] as? Data,
                       let book = try? JSONDecoder().decode(Book.self, from: bookData) {
                        self.books.append(book)
                    }
                case "updateBook":
                    if let bookData = message["book"] as? Data,
                       let updatedBook = try? JSONDecoder().decode(Book.self, from: bookData),
                        let index = self.books.firstIndex(where: { $0.id == updatedBook.id }) {
                        self.books[index] = updatedBook
                    }
                case "deleteBook":
                    if let bookId = message["bookId"] as? String,
                       let index = self.books.firstIndex(where: { $0.id.uuidString == bookId }) {
                        self.books.remove(at: index)
                    }
                default:
                    break
                }
            }
        }
    }
    
    func sendBooksToWatch() {
        if WCSession.default.isReachable {
            do {
                let data = try JSONEncoder().encode(books)
                WCSession.default.sendMessage(["type": "syncBooks", "books": data], replyHandler: nil) { error in
                    print("Error sending books to watch: \(error.localizedDescription)")
                }
            } catch {
                print("Error encoding books: \(error.localizedDescription)")
            }
        }
    }
}
