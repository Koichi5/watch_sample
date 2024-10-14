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
                .onDelete(perform: deleteRecord)
                .refreshable {
                    recordManager.fetchRecords()
                }
            }
        }
    }
    
    private func deleteRecord(at offset: IndexSet) {
        offset.forEach { index in
            recordManager.deleteRecord(recordManager.records[index])
        }
    }
}

struct RecordRow: View {
    let record: Record
    let geometry: GeometryProxy
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter
    }()
    
    var body: some View {
        let imageUrl = URL(string: record.book.imageUrl)
        HStack {
            AsyncImage(url: imageUrl) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: geometry.size.width * 0.13, height: geometry.size.width * 0.13 * 1.5)
            VStack(alignment: .leading, spacing: 8) {
                Text(record.book.title)
                    .font(.headline)
                Text(dateFormatter.string(from: record.createdAt))
                    .font(.caption)
                    .foregroundStyle(Color.gray)
            }
            .padding()
            Spacer()
            Text(formatTime(seconds: record.seconds))
                .font(.title)
                .fontWeight(.bold)
        }
    }
    
    private func formatTime(seconds totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        var components = [String]()
        
        if hours > 0 {
            components.append("\(hours)")
        }
        
        if minutes > 0 {
            // hoursが0の場合はゼロ埋めしない
            let minuteString = hours > 0 ? String(format: "%02d", minutes) : "\(minutes)"
            components.append(minuteString)
        }
        
        if seconds > 0 {
            // hoursまたはminutesが0より大きい場合はゼロ埋め
            let secondString = (hours > 0 || minutes > 0) ? String(format: "%02d", seconds) : "\(seconds)"
            components.append(secondString)
        }
        
        // すべての値が0の場合は"0"を返す
        if components.isEmpty {
            return "0"
        } else {
            return components.joined(separator: " : ")
        }
    }
}
