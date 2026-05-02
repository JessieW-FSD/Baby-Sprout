import SwiftUI
import SwiftData

struct FeedingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FeedingEntry.timestamp, order: .reverse) private var feedings: [FeedingEntry]
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(feedings) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.summary)
                            .font(.body)
                        Text(entry.timestamp, format: .dateTime.month().day().hour().minute())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if !entry.notes.isEmpty {
                            Text(entry.notes)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteEntries)
            }
            .navigationTitle("Feeding")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddFeedingView()
            }
            .overlay {
                if feedings.isEmpty {
                    ContentUnavailableView("No Feedings", systemImage: "cup.and.saucer", description: Text("Tap + to log a feeding"))
                }
            }
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(feedings[index])
        }
    }
}
