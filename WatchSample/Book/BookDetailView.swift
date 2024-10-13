//
//  BookDetailView.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/13.
//

import SwiftUI
import SwiftData

struct BookDetailView: View {
    let book: Book
    @ObservedObject var recordManager: RecordManager
    @State private var seconds: Int = 0
    @State private var isStudying: Bool = false
    @State private var timer: Timer?
    
    var body: some View {
        let imageUrl = URL(string: book.imageUrl)
        NavigationStack {
            GeometryReader { geometry in
                HStack(alignment: .center) {
                    VStack(alignment: .center) {
                        AsyncImage(url: imageUrl) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4 * 1.5)
                        
                        Text(book.title)
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Text(formatTime(seconds: seconds))
                            .font(.largeTitle)
                            .padding()
                        
                        Button(action: {
                            isStudying.toggle()
                            if isStudying {
                                startTimer()
                            } else {
                                stopTimer()
                            }
                        }) {
                            Text(isStudying ? "Stop" : "Start")
                                .frame(minWidth: 0, maxWidth: .infinity)
                        }
                        .buttonStyle(StudyButtonStyle(isStudying: isStudying))
                        .padding()
                        
                        Spacer()
                        Button(action: {
                            recordManager.addRecord(book: book, seconds: seconds)
                            stopTimer()
                            seconds = 0
                            isStudying = false
                        }) {
                            Text("Save")
                                .frame(minWidth: 0, maxWidth: .infinity)
                        }
                        .buttonStyle(StudyButtonStyle())
                        .padding()
                    }
                    .padding()
                }
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            seconds += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct StudyButtonStyle: ButtonStyle {
    var isStudying: Bool?
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(isStudying ?? false ? Color.red : Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
