//
//  TodoView.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/08.
//

import SwiftUI
import SwiftData

struct TodoView: View {
    @StateObject private var todoManager = TodoManager()
    @State private var newTodoTitle = ""

    var body: some View {
        List {
            TextField("New Todo", text: $newTodoTitle, onCommit: addTodo)
            
            ForEach(todoManager.todos) { todo in
                TodoRow(todo: todo, updateTodo: todoManager.updateTodo)
            }
            .onDelete(perform: deleteTodos)
        }
        .navigationTitle("Todos")
    }

    private func addTodo() {
        let newTodo = Todo(title: newTodoTitle)
        todoManager.addTodo(newTodo)
        newTodoTitle = ""
    }

    private func deleteTodos(at offsets: IndexSet) {
        offsets.forEach { index in
            todoManager.deleteTodo(todoManager.todos[index])
        }
    }
}

struct TodoRow: View {
    let todo: Todo
    let updateTodo: (Todo) -> Void

    var body: some View {
        Toggle(isOn: Binding(
            get: { todo.isCompleted },
            set: { newValue in
                todo.isCompleted = newValue
                updateTodo(todo)
            }
        )) {
            Text(todo.title)
        }
    }
}
