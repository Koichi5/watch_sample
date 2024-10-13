//
//  ExtensionDelegate.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/13.
//

import Foundation
import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    override init() {
        super.init()
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // データの受信はWatchConnectivityManagerで処理するため、ここではタスクを完了
                connectivityTask.setTaskCompletedWithSnapshot(false)
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
}

