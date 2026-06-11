import SwiftUI
import SwiftData

struct DiaperListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DiaperEntry.timestamp, order: .reverse) private var diapers: [DiaperEntry]
    @AppStorage(AppStorageKeys.dayStartHour) private var dayStartHour = 8
    @State private var showAddSheet = false
    @State private var entryToEdit: DiaperEntry?

    private var grouped: [(day: Date, items: [DiaperEntry])] {
        DayBoundary.group(diapers, by: \.timestamp, startHour: dayStartHour)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Quick Add") {
                    HStack(spacing: 12) {
                        ForEach(DiaperType.allCases, id: \.self) { type in
                            Button {
                                quickAdd(type)
                            } label: {
                                VStack {
                                    Image(systemName: type.icon)
                                        .font(.title2)
                                    Text(type.rawValue)
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }

                ForEach(grouped, id: \.day) { day, entries in
                    Section(DayBoundary.label(for: day, startHour: dayStartHour)) {
                        ForEach(entries) { entry in
                            HStack {
                                Image(systemName: entry.diaperType.icon)
                                    .foregroundStyle(colorForType(entry.diaperType))
                                VStack(alignment: .leading) {
                                    HStack(spacing: 4) {
                                        Text(entry.diaperType.rawValue)
                                        if let pooAmount = entry.pooAmount {
                                            Text("·")
                                                .foregroundStyle(.secondary)
                                            Text(pooAmount.rawValue)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .font(.body)
                                    Text(entry.timestamp, format: .dateTime.hour().minute())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                if !entry.notes.isEmpty {
                                    Spacer()
                                    Text(entry.notes)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
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
            .navigationTitle("Diapers")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddDiaperView()
            }
            .sheet(item: $entryToEdit) { entry in
                AddDiaperView(entryToEdit: entry)
            }
            .overlay {
                if diapers.isEmpty {
                    ContentUnavailableView("No Diapers", systemImage: "drop", description: Text("Tap + or use Quick Add to log a diaper change"))
                }
            }
        }
    }

    private func quickAdd(_ type: DiaperType) {
        let entry = DiaperEntry(diaperType: type)
        modelContext.insert(entry)
        ReminderManager.reschedule()
    }

    private func colorForType(_ type: DiaperType) -> Color {
        switch type {
        case .pee: return .yellow
        case .poo: return .brown
        case .both: return .orange
        }
    }
}
