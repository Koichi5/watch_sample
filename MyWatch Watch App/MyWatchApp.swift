//
//  MyWatchApp.swift
//  MyWatch Watch App
//
//  Created by Koichi Kishimoto on 2024/10/08.
//

// TodoApp
//import SwiftUI
//import SwiftData
//
//@main
//struct MyWatch_Watch_AppApp: App {
//    var body: some Scene {
//        WindowGroup {
//            TodoView()
//        }
//        .modelContainer(for: Todo.self)
//    }
//}

// BookApp
import SwiftUI
import WatchKit

@main
struct BookApp: App {
    let dataController = DataController.shared
    let connectivityManager = WatchConnectivityManager.shared // ここで初期化

    var body: some Scene {
        WindowGroup {
            BookView()
                .environmentObject(dataController)
        }
        .modelContainer(dataController.container)
    }
}
