import SwiftUI
import SwiftData

struct CustomEventListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CustomEventEntry.timestamp, order: .reverse) private var events: [CustomEventEntry]
    @AppStorage(AppStorageKeys.dayStartHour) private var dayStartHour = 8
    @State private var showAddSheet = false
    @State private var entryToEdit: CustomEventEntry?

    private var grouped: [(day: Date, items: [CustomEventEntry])] {
        DayBoundary.group(events, by: \.timestamp, startHour: dayStartHour)
    }

    var body: some View {
        List {
            ForEach(grouped, id: \.day) { day, entries in
                Section(DayBoundary.label(for: day, startHour: dayStartHour)) {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.title)
                                .font(.body)
                                .fontWeight(.medium)
                            Text(entry.timestamp, format: .dateTime.hour().minute())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if !entry.eventDescription.isEmpty {
                                Text(entry.eventDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            if !entry.photoDataArray.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 4) {
                                        ForEach(entry.photoDataArray.indices, id: \.self) { index in
                                            if let uiImage = UIImage(data: entry.photoDataArray[index]) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 48, height: 48)
                                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                                    .accessibilityLabel("Photo \(index + 1) of \(entry.photoDataArray.count) for \(entry.title)")
                                            }
                                        }
                                    }
                                }
                            }
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
        .navigationTitle("Events")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showAddSheet = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddCustomEventView()
        }
        .sheet(item: $entryToEdit) { entry in
            AddCustomEventView(entryToEdit: entry)
        }
        .overlay {
            if events.isEmpty {
                ContentUnavailableView("No Events", systemImage: "note.text", description: Text("Tap + to log an event"))
            }
        }
    }
}
