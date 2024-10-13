//
//  BookView.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/09.
//

import SwiftUI
import SwiftData

struct BookView: View {
    @ObservedObject var bookManager = BookManager()
    @ObservedObject var recordManager: RecordManager
    
    var body: some View {
        GeometryReader { geometry in
            List {
                ForEach(bookManager.books) { book in
                    BookRow(book: book, geometry: geometry, recordManager: recordManager)
                }
                .onDelete(perform: deleteBooks)
            }
        }
    }
    
    private func deleteBooks(at offset: IndexSet) {
        offset.forEach { index in
            bookManager.deleteBook(bookManager.books[index])
        }
    }
}

struct BookRow: View {
    let book: Book
    let geometry: GeometryProxy
    let recordManager: RecordManager
    
    var body: some View {
        let imageUrl = URL(string: book.imageUrl)
        NavigationLink(destination: BookDetailView(book: book, recordManager: recordManager)) {
            HStack {
                AsyncImage(url: imageUrl) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: geometry.size.width * 0.13, height: geometry.size.width * 0.13 * 1.5)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(book.title)
                        .font(.headline)
                    Text(book.publisher)
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                }
                .padding()
            }
        }
    }
}
