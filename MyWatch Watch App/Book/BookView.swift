//
//  BookView.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/09.
//

import SwiftUI
import SwiftData

struct BookView: View {
    @StateObject private var bookManager = BookManager()
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                List {
                    ForEach(bookManager.books) { book in
                        BookRow(book: book, geometry: geometry)
                    }
                    .onDelete(perform: deleteBooks)
                }
                .navigationTitle("Books")
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
    
    var body: some View {
        let imageUrl = URL(string: book.imageUrl)
        HStack {
            AsyncImage(url: imageUrl) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15 * 1.5)
            VStack {
                Text(book.title)
                Text(book.publisher)
            }
        }
    }
}
