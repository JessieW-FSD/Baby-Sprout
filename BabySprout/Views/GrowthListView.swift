import SwiftUI
import SwiftData

struct GrowthListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GrowthEntry.date, order: .reverse) private var entries: [GrowthEntry]
    @AppStorage(AppStorageKeys.dayStartHour) private var dayStartHour = 8
    @State private var showAddSheet = false
    @State private var entryToEdit: GrowthEntry?

    private var grouped: [(day: Date, items: [GrowthEntry])] {
        DayBoundary.group(entries, by: \.date, startHour: dayStartHour)
    }

    var body: some View {
        List {
            ForEach(grouped, id: \.day) { day, dayEntries in
                Section(DayBoundary.label(for: day, startHour: dayStartHour)) {
                    ForEach(dayEntries) { entry in
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
                        .swipeActions(edge: .leading) {
                            Button("Edit") { entryToEdit = entry }
                                .tint(.blue)
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            modelContext.delete(dayEntries[index])
                        }
                    }
                }
            }
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
        .sheet(item: $entryToEdit) { entry in
            AddGrowthView(entryToEdit: entry)
        }
        .overlay {
            if entries.isEmpty {
                ContentUnavailableView("No Measurements", systemImage: "chart.bar.fill", description: Text("Tap + to log growth"))
            }
        }
    }
}
