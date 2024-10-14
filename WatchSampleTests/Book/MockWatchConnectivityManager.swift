//
//  MockWatchConnectivityManager.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/14.
//

import Foundation
import WatchConnectivity
@testable import WatchSample

class MockWatchConnectivityManager: WatchConnectivityManager {
    var sentData: Data?

    override init(session: WCSessionProtocol = WCSession.default, dataController: DataControllerProtocol = DataController.shared) {
        super.init(session: session, dataController: dataController)
        // 必要に応じて追加の初期化コードをここに書きます
    }

    override func sendData(_ data: Data) {
        // データ送信を実際には行わず、テスト用にデータを保持
        sentData = data
    }
}
