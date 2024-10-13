//
//  TodoManager.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/08.
//

import SwiftData
import WatchConnectivity

@MainActor
class TodoManager: NSObject, ObservableObject {
    let modelContainer: ModelContainer
    let modelContext: ModelContext
    
    @Published var todos: [Todo] = []
    
    override init() {
        do {
            modelContainer = try ModelContainer(for: Todo.self)
            modelContext = modelContainer.mainContext
        } catch {
            fatalError("Failed to create ModelContainer for Todo: \(error.localizedDescription)")
        }
        
        super.init()
        
        fetchTodos()
        setupWatchConnectivity()
    }
    
    func fetchTodos() {
        let descriptor = FetchDescriptor<Todo>(sortBy: [SortDescriptor(\.lastModified)])
        do {
            todos = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching todos: \(error.localizedDescription)")
        }
    }
    
    func addTodo(_ todo: Todo) {
        modelContext.insert(todo)
        saveTodos()
        sendTodosToPhone()
    }
    
    func updateTodo(_ todo: Todo) {
        todo.lastModified = Date()
        saveTodos()
        sendTodosToPhone()
    }
    
    func deleteTodo(_ todo: Todo) {
        modelContext.delete(todo)
        saveTodos()
        sendTodosToPhone()
    }
    
    private func saveTodos() {
        do {
            try modelContext.save()
            fetchTodos()
        } catch {
            print("Error saving todos: \(error.localizedDescription)")
        }
    }
    
    // WatchConnectivity
    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    private func sendTodosToPhone() {
        guard WCSession.default.isReachable else {
            print("Phone is not reachable")
            return
        }
        
        do {
            let encodedTodos = try JSONEncoder().encode(todos)
            WCSession.default.sendMessage(["todos": encodedTodos], replyHandler: { reply in
                print("Message sent successfully to phone. Reply: \(reply)")
            }) { error in
                print("Error sending todos to phone: \(error.localizedDescription)")
            }
        } catch {
            print("Error encoding todos: \(error.localizedDescription)")
        }
    }
}

extension TodoManager: WCSessionDelegate {
    nonisolated func session(
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
    
    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any],
        replyHandler: @escaping ([String : Any]) -> Void
    ) {
        guard let encodedTodos = message["todos"] as? Data else {
            print("Received message does not contain todos data")
            replyHandler(["status": "error", "message": "Invalid data received"])
            return
        }
        
        do {
            let decodedTodos = try JSONDecoder().decode([Todo].self, from: encodedTodos)
            DispatchQueue.main.async {
                self.updateLocalTodos(with: decodedTodos)
                replyHandler(["status": "success"])
            }
        } catch {
            print("Error decoding todos: \(error.localizedDescription)")
            replyHandler(["status": "error", "message": "Failed to decode todos"])
        }
    }
    
    private func updateLocalTodos(with receivedTodos: [Todo]) {
        for todo in todos {
            modelContext.delete(todo)
        }
        todos = receivedTodos
        
        for todo in todos {
            modelContext.insert(todo)
        }
        
        saveTodos()
    }
}
