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

    private var session: WCSessionProtocol
    private let dataController: DataControllerProtocol

    // 依存性注入を可能にする初期化子
    init(session: WCSessionProtocol = WCSession.default, dataController: DataControllerProtocol = DataController.shared) {
        self.session = session
        self.dataController = dataController
        super.init()

        if WCSession.isSupported() {
            self.session.delegate = self
            self.session.activate()
        }
    }

    func sendData(_ data: Data) {
        if session.isReachable {
            session.sendMessage(["data": data], replyHandler: { reply in
                print("Send data Reply: \(reply)")
            }) { error in
                print("Error sending data via sendMessage: \(error.localizedDescription)")
            }
        } else {
            do {
                try session.updateApplicationContext(["data": data])
            } catch {
                print("Error sending data via updateApplicationContext: \(error.localizedDescription)")
                session.transferUserInfo(["data": data])
            }
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    // デリゲートメソッド内で 'session' を使用するように修正
    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        self.session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = self.session.isReachable
        }
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = self.session.isReachable
        }
        print("Session reachability changed: \(self.session.isReachable)")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) async {
        await handleReceivedData(message)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) async {
        await handleReceivedData(applicationContext)
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) async {
        await handleReceivedData(userInfo)
    }

    private func handleReceivedData(_ dataDictionary: [String: Any]) async {
        print("Received data dictionary: \(dataDictionary)")
        guard let data = dataDictionary["data"] as? Data else {
            print("Invalid data received")
            return
        }
        print("Data received: \(data.count) bytes")
        await DataController.shared.processReceivedData(data)
    }
}
