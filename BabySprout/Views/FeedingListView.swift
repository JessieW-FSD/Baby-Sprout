import SwiftUI
import SwiftData

struct FeedingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FeedingEntry.timestamp, order: .reverse) private var feedings: [FeedingEntry]
    @AppStorage(AppStorageKeys.dayStartHour) private var dayStartHour = 8
    @State private var showAddSheet = false
    @State private var entryToEdit: FeedingEntry?

    private var grouped: [(day: Date, items: [FeedingEntry])] {
        DayBoundary.group(feedings, by: \.timestamp, startHour: dayStartHour)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(grouped, id: \.day) { day, entries in
                    Section(DayBoundary.label(for: day, startHour: dayStartHour)) {
                        ForEach(entries) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.summary)
                                    .font(.body)
                                Text(entry.timestamp, format: .dateTime.hour().minute())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if !entry.notes.isEmpty {
                                    Text(entry.notes)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button("Edit") { entryToEdit = entry }
                                    .tint(.blue)
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                modelContext.delete(entries[index])
                            }
                        }
                    }
                }
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
            .sheet(item: $entryToEdit) { entry in
                AddFeedingView(entryToEdit: entry)
            }
            .overlay {
                if feedings.isEmpty {
                    ContentUnavailableView("No Feedings", systemImage: "cup.and.saucer", description: Text("Tap + to log a feeding"))
                }
            }
        }
    }
}
