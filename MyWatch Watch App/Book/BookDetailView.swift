//
//  BookDetailView.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/13.
//

import SwiftUI

struct BookDetailView: View {
    let book: Book
    @ObservedObject var recordManager: RecordManager

    @State private var seconds: Int = 0
    @State private var isStudying: Bool = false
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 10) {
            AsyncImage(url: URL(string: book.imageUrl)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 120)
            .cornerRadius(5)

            Text(book.title)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(formatTime(seconds: seconds))
                .font(.title2)
                .bold()

            HStack {
                Button(action: {
                    isStudying.toggle()
                    if isStudying {
                        startTimer()
                    } else {
                        stopTimer()
                    }
                }) {
                    Text(isStudying ? "Stop" : "Start")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(StudyButtonStyle(isStudying: isStudying))

                Button(action: {
                    saveRecord()
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(StudyButtonStyle())
                .disabled(seconds == 0)
            }
            .padding(.top, 10)
        }
        .padding()
        .navigationTitle("Reading")
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

    private func saveRecord() {
        recordManager.addRecord(book: book, seconds: seconds)
        stopTimer()
        seconds = 0
        isStudying = false
    }

    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct StudyButtonStyle: ButtonStyle {
    var isStudying: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(isStudying ? Color.red : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}
