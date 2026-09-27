import SwiftUI

struct TodoItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isDone: Bool = false
}

struct ContentView: View {
    @State private var items: [TodoItem] = []
    @State private var newTitle: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                list
                inputBar
            }
            .navigationTitle("MyApp")
        }
    }

    private var list: some View {
        List {
            if items.isEmpty {
                ContentUnavailableView(
                    "No Tasks",
                    systemImage: "checkmark.circle",
                    description: Text("Add your first task below.")
                )
            } else {
                ForEach(items) { item in
                    row(for: item)
                }
                .onDelete { offsets in
                    items.remove(atOffsets: offsets)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func row(for item: TodoItem) -> some View {
        HStack {
            Button {
                toggle(item)
            } label: {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
            }
            .buttonStyle(.plain)

            Text(item.title)
                .strikethrough(item.isDone, color: .secondary)
                .foregroundStyle(item.isDone ? .secondary : .primary)

            Spacer()
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("New task", text: $newTitle)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
                .onSubmit(add)

            Button(action: add) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
            .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
        .background(.bar)
    }

    private func add() {
        let trimmed = newTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        items.append(TodoItem(title: trimmed))
        newTitle = ""
    }

    private func toggle(_ item: TodoItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isDone.toggle()
    }
}

#Preview {
    ContentView()
}
