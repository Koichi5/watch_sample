//
//  HomeView.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/13.
//

import SwiftUI

struct HomeView: View {
    enum Tabs: String {
        case tab1 = "Books"
        case tab2 = "Records"
    }
    
    @State private var selectedTab: Tabs = .tab1
    @StateObject private var bookManager = BookManager()
    @StateObject private var recordManager = RecordManager()

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                BookView(
                    bookManager: bookManager,
                    recordManager: recordManager
                )
                    .tabItem {
                        Label("Books", systemImage: "book.fill")
                    }
                    .tag(Tabs.tab1)
                
                RecordView(recordManager: recordManager)
                    .tabItem {
                        Label("Records", systemImage: "list.bullet.clipboard")
                    }
                    .tag(Tabs.tab2)
            }
            .navigationTitle(selectedTab.rawValue)
            .toolbar {
                if selectedTab == .tab1 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: AddBookView(addBook: addBook)) {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }
        }
    }
    
    private func addBook(title: String, publisher: String, imageUrl: String) {
        let newBook = Book(title: title, publisher: publisher, imageUrl: imageUrl)
        bookManager.addBook(newBook)
        bookManager.fetchBooks()
    }
}
