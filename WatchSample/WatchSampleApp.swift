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
//struct WatchSampleApp: App {
//    var body: some Scene {
//        WindowGroup {
//            TodoView()
//        }
//        .modelContainer(for: Todo.self)
//    }
//}


// BookApp
import SwiftUI

@main
struct BookApp: App {
    let dataController = DataController.shared
    let connectivityManager = WatchConnectivityManager.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(dataController)
        }
        .modelContainer(dataController.container)
    }
}
