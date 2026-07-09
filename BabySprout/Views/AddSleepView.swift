import SwiftUI
import SwiftData
import WidgetKit

struct AddSleepView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var entryToEdit: SleepEntry?
    private var isEditing: Bool { entryToEdit != nil }

    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var isStillSleeping = false
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Start", selection: $startTime, in: ...Date.now, displayedComponents: [.date, .hourAndMinute])
                    Toggle("Still sleeping", isOn: $isStillSleeping)
                    if !isStillSleeping {
                        DatePicker("End", selection: $endTime, in: startTime...Date.now, displayedComponents: [.date, .hourAndMinute])
                    }
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .onAppear { populateFromEntry() }
            .navigationTitle(isEditing ? "Edit Sleep" : "Log Sleep")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
        }
    }

    private func populateFromEntry() {
        guard let entry = entryToEdit else { return }
        startTime = entry.startTime
        if let end = entry.endTime {
            endTime = end
            isStillSleeping = false
        } else {
            isStillSleeping = true
        }
        notes = entry.notes
    }

    private func save() {
        let resolvedEndTime = isStillSleeping ? nil : endTime
        if let entry = entryToEdit {
            entry.startTime = startTime
            entry.endTime = resolvedEndTime
            entry.notes = notes
        } else {
            let entry = SleepEntry(startTime: startTime, endTime: resolvedEndTime, notes: notes)
            modelContext.insert(entry)
        }
        ReminderManager.reschedule()
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }
}
