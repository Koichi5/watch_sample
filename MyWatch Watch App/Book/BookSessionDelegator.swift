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
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let type = message["type"] as? String, type == "syncBooks",
               let bookData = message["books"] as? Data,
               let receivedBooks = try? JSONDecoder().decode([Book].self, from: bookData) {
                self.books = receivedBooks
            }
        }
    }
    
    func sendToPhone(type: String, book: Book) {
        if WCSession.default.isReachable {
            do {
                let data = try JSONEncoder().encode(book)
                WCSession.default.sendMessage(["type": type, "book": book], replyHandler: { reply in
                    print("Send data Reply: \(reply)")
                }) { error in
                    print("Error sending book to phone: \(error.localizedDescription)")
                }
            } catch {
                print("Error encoding book: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteBookOnPhone(bookId: UUID) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["type": "deleteBook", "bookId": bookId.uuidString], replyHandler: { reply in
                print("Delete Book data Reply: \(reply)")
            }) { error in
                print("Error sending delete request to phone: \(error.localizedDescription)")
            }
        }
    }
}
