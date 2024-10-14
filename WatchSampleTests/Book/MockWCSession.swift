//
//  MockWCSession.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/14.
//

// MockWCSession.swift

import WatchConnectivity
@testable import WatchSample

class MockWCSession: WCSessionProtocol {
    var isReachable: Bool = false
    var activationState: WCSessionActivationState = .notActivated
    weak var delegate: WCSessionDelegate?

    var didActivateCalled = false
    var sentMessages: [[String: Any]] = []
    var applicationContext: [String: Any] = [:]
    var transferredUserInfo: [[String: Any]] = []

    func activate() {
        didActivateCalled = true
        activationState = .activated
        delegate?.session(WCSession.default, activationDidCompleteWith: .activated, error: nil)
    }

    func sendMessage(_ message: [String : Any], replyHandler: (([String : Any]) -> Void)?, errorHandler: ((Error) -> Void)?) {
        sentMessages.append(message)
        // 必要に応じて replyHandler を呼び出す
    }

    func updateApplicationContext(_ applicationContext: [String : Any]) throws {
        self.applicationContext = applicationContext
    }

    func transferUserInfo(_ userInfo: [String : Any]) -> WCSessionUserInfoTransfer {
        transferredUserInfo.append(userInfo)
        return WCSessionUserInfoTransfer()
    }
}
