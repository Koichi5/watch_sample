////
////  SessionDelegator.swift
////  WatchSample
////
////  Created by Koichi Kishimoto on 2024/10/08.
////
//
//import Foundation
//import WatchConnectivity
//
//class SessionDelegator: NSObject, WCSessionDelegate, ObservableObject {
//    @Published var todos: [Todo] = []
//    
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        // Handle session activation
//    }
//    
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        DispatchQueue.main.async {
//            if let type = message["type"] as? String, type == "syncTodos",
//               let todoData = message["todos"] as? Data,
//               let receivedTodos = try? JSONDecoder().decode([Todo].self, from: todoData) {
//                self.todos = receivedTodos
//            }
//        }
//    }
//    
//    func sendTodoToPhone(type: String, todo: Todo) {
//        if WCSession.default.isReachable {
//            do {
//                let data = try JSONEncoder().encode(todo)
//                WCSession.default.sendMessage(["type": type, "todo": data], replyHandler: nil) { error in
//                    print("Error sending todo to phone: \(error.localizedDescription)")
//                }
//            } catch {
//                print("Error encoding todo: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    func deleteTodoOnPhone(todoId: UUID) {
//        if WCSession.default.isReachable {
//            WCSession.default.sendMessage(["type": "deleteTodo", "todoId": todoId.uuidString], replyHandler: nil) { error in
//                print("Error sending delete request to phone: \(error.localizedDescription)")
//            }
//        }
//    }
//}
