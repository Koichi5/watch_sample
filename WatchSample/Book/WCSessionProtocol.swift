//
//  WCSessionProtocol.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/14.
//

import WatchConnectivity

protocol WCSessionProtocol {
    var isReachable: Bool { get }
    var activationState: WCSessionActivationState { get }
    var delegate: WCSessionDelegate? { get set }

    func activate()
    func sendMessage(_ message: [String : Any], replyHandler: (([String : Any]) -> Void)?, errorHandler: ((Error) -> Void)?)
    func updateApplicationContext(_ applicationContext: [String : Any]) throws
    func transferUserInfo(_ userInfo: [String : Any]) -> WCSessionUserInfoTransfer
}

extension WCSession: WCSessionProtocol {}
