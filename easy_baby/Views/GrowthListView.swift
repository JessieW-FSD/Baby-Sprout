import SwiftUI
import SwiftData

struct GrowthListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GrowthEntry.date, order: .reverse) private var entries: [GrowthEntry]
    @State private var showAddSheet = false

    var body: some View {
        List {
            ForEach(entries) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.summary)
                        .font(.body)
                    Text(entry.date, format: .dateTime.month().day().year())
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
        .navigationTitle("Growth")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showAddSheet = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddGrowthView()
        }
        .overlay {
            if entries.isEmpty {
                ContentUnavailableView("No Measurements", systemImage: "chart.bar.fill", description: Text("Tap + to log growth"))
            }
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }
    }
}
