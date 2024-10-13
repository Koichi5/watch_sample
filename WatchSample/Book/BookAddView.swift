//
//  BookAddView.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/13.
//

import SwiftUI

struct AddBookView: View {
    let addBook: (_ title: String, _ publisher: String, _ imageUrl: String) -> Void
    
    @State private var bookTitle = ""
    @State private var bookPublisher = ""
    @State private var bookImageUrl = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                    TextField("Title", text: $bookTitle)
                    .padding()
                    TextField("Publisher", text: $bookPublisher)
                    .padding()
                    TextField("Image URL", text: $bookImageUrl)
                    .padding()
                Spacer()
                Button(action: {
                    addBook(bookTitle, bookPublisher, bookImageUrl)
                }, label: {
                    Text("Add Book")
                })
                .padding()
            }
            .navigationTitle("Add Book")
            .padding()
        }
    }
}
