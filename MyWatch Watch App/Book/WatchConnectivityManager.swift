//
//  WatchConnectivityManager.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/13.
//

import Foundation
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var isReachable = false

    private override init() {
        super.init()

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func sendData(_ data: Data) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["data": data], replyHandler: nil) { error in
                print("Error sending data via sendMessage: \(error.localizedDescription)")
            }
        } else {
            do {
                try WCSession.default.updateApplicationContext(["data": data])
            } catch {
                print("Error sending data via updateApplicationContext: \(error.localizedDescription)")
                WCSession.default.transferUserInfo(["data": data])
            }
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
            // 必要に応じてデータの同期を開始
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
        print("Session reachability changed: \(session.isReachable)")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleReceivedData(message)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        handleReceivedData(applicationContext)
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        handleReceivedData(userInfo)
    }

    private func handleReceivedData(_ dataDictionary: [String: Any]) {
        print("Received data dictionary: \(dataDictionary)")
        guard let data = dataDictionary["data"] as? Data else {
            print("Invalid data received")
            return
        }
        print("Data received: \(data.count) bytes")
        DataController.shared.processReceivedData(data)
    }
}
