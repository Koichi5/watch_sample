//
//  BookView.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/09.
//

// BookView.swift (watchOS)

import SwiftUI
import SwiftData

struct BookView: View {
    @StateObject private var bookManager = BookManager()
    @StateObject private var recordManager = RecordManager()

    var body: some View {
        NavigationStack {
            List {
                ForEach(bookManager.books) { book in
                    NavigationLink(destination: BookDetailView(book: book, recordManager: recordManager)) {
                        BookRow(book: book)
                    }
                }
                .onDelete(perform: deleteBooks)
            }
            .navigationTitle("Books")
        }
    }

    private func deleteBooks(at offsets: IndexSet) {
        offsets.forEach { index in
            bookManager.deleteBook(bookManager.books[index])
        }
    }
}


struct BookRow: View {
    let book: Book

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: book.imageUrl)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40, height: 60)
            .cornerRadius(5)

            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)
                Text(book.publisher)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}
