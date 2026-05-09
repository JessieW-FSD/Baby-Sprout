import SwiftUI
import SwiftData

struct AddSupplementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var entryToEdit: SupplementEntry?
    private var isEditing: Bool { entryToEdit != nil }

    @State private var timestamp = Date()
    @State private var name = ""
    @State private var dosage = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Time") {
                    DatePicker("Time", selection: $timestamp, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Details") {
                    TextField("Name (e.g., Vitamin D)", text: $name)
                    TextField("Dosage (e.g., 400 IU)", text: $dosage)
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .onAppear { populateFromEntry() }
            .navigationTitle(isEditing ? "Edit Supplement" : "Log Supplement")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func populateFromEntry() {
        guard let entry = entryToEdit else { return }
        timestamp = entry.timestamp
        name = entry.name
        dosage = entry.dosage
        notes = entry.notes
    }

    private func save() {
        if let entry = entryToEdit {
            entry.timestamp = timestamp
            entry.name = name
            entry.dosage = dosage
            entry.notes = notes
        } else {
            let entry = SupplementEntry(timestamp: timestamp, name: name, dosage: dosage, notes: notes)
            modelContext.insert(entry)
        }
        ReminderManager.reschedule()
        dismiss()
    }
}
