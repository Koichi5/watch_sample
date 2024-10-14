//
//  SyncData.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/14.
//

import Foundation

struct SyncData: Codable {
    let books: [Book]
    let records: [RecordDTO]
}
