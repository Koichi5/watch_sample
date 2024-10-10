//
//  Item.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/08.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
