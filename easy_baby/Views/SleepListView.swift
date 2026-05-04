import SwiftUI
import SwiftData

struct SleepListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SleepEntry.startTime, order: .reverse) private var sleeps: [SleepEntry]
    @AppStorage("dayStartHour") private var dayStartHour = 8
    @State private var showAddSheet = false
    @State private var entryToEnd: SleepEntry?
    @State private var entryToEdit: SleepEntry?

    private var grouped: [(day: Date, items: [SleepEntry])] {
        DayBoundary.group(sleeps, by: \.startTime, startHour: dayStartHour)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(grouped, id: \.day) { day, entries in
                    Section(DayBoundary.label(for: day, startHour: dayStartHour)) {
                        ForEach(entries) { entry in
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
                                    Text(entry.startTime, format: .dateTime.hour().minute())
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
                                    Button("Wake") { entryToEnd = entry }
                                        .tint(.orange)
                                } else {
                                    Button("Edit") { entryToEdit = entry }
                                        .tint(.blue)
                                }
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
            .sheet(item: $entryToEnd) { entry in
                EndSleepView(entry: entry)
            }
            .sheet(item: $entryToEdit) { entry in
                AddSleepView(entryToEdit: entry)
            }
            .overlay {
                if sleeps.isEmpty {
                    ContentUnavailableView("No Sleep Records", systemImage: "moon", description: Text("Tap + to log sleep"))
                }
            }
        }
    }
}

struct EndSleepView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var entry: SleepEntry
    @State private var wakeTime = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Fell asleep") {
                        Text(entry.startTime, format: .dateTime.month().day().hour().minute())
                    }
                    DatePicker("Woke up", selection: $wakeTime, in: entry.startTime...Date.now, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Duration") {
                    let duration = wakeTime.timeIntervalSince(entry.startTime)
                    let hours = Int(duration) / 3600
                    let minutes = (Int(duration) % 3600) / 60
                    Text(hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
            .navigationTitle("End Sleep")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        entry.endTime = wakeTime
                        ReminderManager.reschedule()
                        dismiss()
                    }
                }
            }
        }
    }
}
