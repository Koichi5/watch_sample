//
//  MyWatchApp.swift
//  MyWatch Watch App
//
//  Created by Koichi Kishimoto on 2024/10/08.
//

// TodoApp
//import SwiftUI
//
//@main
//struct MyWatch_Watch_AppApp: App {
//    var body: some Scene {
//        WindowGroup {
//            TodoView()
//        }
//    }
//}

// BookApp
import SwiftUI
import SwiftData

@main
struct BookApp: App {
    var body: some Scene {
        WindowGroup {
            BookView()
        }
        .modelContainer(for: Book.self)
    }
}
