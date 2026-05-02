import SwiftUI
import SwiftData

struct SupplementListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SupplementEntry.timestamp, order: .reverse) private var supplements: [SupplementEntry]
    @State private var showAddSheet = false

    var body: some View {
        List {
            ForEach(supplements) { entry in
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
        .navigationTitle("Supplements")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showAddSheet = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddSupplementView()
        }
        .overlay {
            if supplements.isEmpty {
                ContentUnavailableView("No Supplements", systemImage: "pill", description: Text("Tap + to log a supplement"))
            }
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(supplements[index])
        }
    }
}
