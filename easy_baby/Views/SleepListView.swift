import SwiftUI
import SwiftData

struct SleepListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SleepEntry.startTime, order: .reverse) private var sleeps: [SleepEntry]
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(sleeps) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(entry.durationFormatted)
                                .font(.body)
                                .fontWeight(entry.isActive ? .bold : .regular)
                            if entry.isActive {
                                Image(systemName: "moon.zzz.fill")
                                    .foregroundStyle(.indigo)
                            }
                        }
                        HStack {
                            Text(entry.startTime, format: .dateTime.month().day().hour().minute())
                            if let endTime = entry.endTime {
                                Text("→")
                                Text(endTime, format: .dateTime.hour().minute())
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        if !entry.notes.isEmpty {
                            Text(entry.notes)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions(edge: .leading) {
                        if entry.isActive {
                            Button("Wake") {
                                entry.endTime = Date()
                            }
                            .tint(.orange)
                        }
                    }
                }
                .onDelete(perform: deleteEntries)
            }
            .navigationTitle("Sleep")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddSleepView()
            }
            .overlay {
                if sleeps.isEmpty {
                    ContentUnavailableView("No Sleep Records", systemImage: "moon", description: Text("Tap + to log sleep"))
                }
            }
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sleeps[index])
        }
    }
}
