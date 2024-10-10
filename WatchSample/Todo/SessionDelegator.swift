//
//  SessionDelegator.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/08.
//

import Foundation
import WatchConnectivity

class SessionDelegator: NSObject, WCSessionDelegate, ObservableObject {
    @Published var todos: [Todo] = []
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle session activation
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session becoming inactive
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Handle session deactivation
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let type = message["type"] as? String {
                switch type {
                case "addTodo":
                    if let todoData = message["todo"] as? Data,
                       let todo = try? JSONDecoder().decode(Todo.self, from: todoData) {
                        self.todos.append(todo)
                    }
                case "updateTodo":
                    if let todoData = message["todo"] as? Data,
                       let updatedTodo = try? JSONDecoder().decode(Todo.self, from: todoData),
                       let index = self.todos.firstIndex(where: { $0.id == updatedTodo.id }) {
                        self.todos[index] = updatedTodo
                    }
                case "deleteTodo":
                    if let todoId = message["todoId"] as? String,
                       let index = self.todos.firstIndex(where: { $0.id.uuidString == todoId }) {
                        self.todos.remove(at: index)
                    }
                default:
                    break
                }
            }
        }
    }
    
    func sendTodosToWatch() {
        if WCSession.default.isReachable {
            do {
                let data = try JSONEncoder().encode(todos)
                WCSession.default.sendMessage(["type": "syncTodos", "todos": data], replyHandler: nil) { error in
                    print("Error sending todos to watch: \(error.localizedDescription)")
                }
            } catch {
                print("Error encoding todos: \(error.localizedDescription)")
            }
        }
    }
}
