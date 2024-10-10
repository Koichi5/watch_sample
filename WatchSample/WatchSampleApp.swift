//
//  WatchSampleApp.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/08.
//

//import SwiftUI
//import SwiftData
//
//@main
//struct WatchSampleApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//        .modelContainer(sharedModelContainer)
//    }
//}

// TodoApp
//import SwiftUI
//import SwiftData
//
//@main
//struct TodoApp: App {
//    var body: some Scene {
//        WindowGroup {
//            TodoView()
//        }
//        .modelContainer(for: Todo.self)
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

