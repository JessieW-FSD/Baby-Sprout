import SwiftUI
import SwiftData

struct SupplementListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SupplementEntry.timestamp, order: .reverse) private var supplements: [SupplementEntry]
    @AppStorage("dayStartHour") private var dayStartHour = 8
    @State private var showAddSheet = false
    @State private var entryToEdit: SupplementEntry?

    private var grouped: [(day: Date, items: [SupplementEntry])] {
        DayBoundary.group(supplements, by: \.timestamp, startHour: dayStartHour)
    }

    var body: some View {
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
        .sheet(item: $entryToEdit) { entry in
            AddSupplementView(entryToEdit: entry)
        }
        .overlay {
            if supplements.isEmpty {
                ContentUnavailableView("No Supplements", systemImage: "pill", description: Text("Tap + to log a supplement"))
            }
        }
    }
}
