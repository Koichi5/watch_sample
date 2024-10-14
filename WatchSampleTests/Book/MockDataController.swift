//
//  Untitled.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/14.
//

import Foundation
@testable import WatchSample

class MockDataController: DataControllerProtocol {
    var receivedData: Data?

    func processReceivedData(_ data: Data) async {
        receivedData = data
    }
}
