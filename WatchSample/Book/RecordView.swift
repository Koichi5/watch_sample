//
//  RecordView.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/09.
//

import SwiftUI

struct RecordView: View {
    @ObservedObject var recordManager: RecordManager
    
    var body: some View {
        GeometryReader { geometry in
            List {
                ForEach(recordManager.records) { record in
                    RecordRow(record: record, geometry: geometry)
                }
            }
        }
    }
}

struct RecordRow: View {
    let record: Record
    let geometry: GeometryProxy
    
    var body: some View {
        let imageUrl = URL(string: record.book.imageUrl)
        HStack {
            AsyncImage(url: imageUrl) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15 * 1.5)
            
            Text(record.seconds.formatted())
        }
    }
}
