//
//  DataControllerProtocol.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/14.
//

import Foundation

protocol DataControllerProtocol {
    func processReceivedData(_ data: Data) async
}

extension DataController: DataControllerProtocol {}
