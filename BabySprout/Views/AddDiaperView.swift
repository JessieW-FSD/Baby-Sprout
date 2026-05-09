import SwiftUI
import SwiftData

struct AddDiaperView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var entryToEdit: DiaperEntry?
    private var isEditing: Bool { entryToEdit != nil }

    @State private var timestamp = Date()
    @State private var diaperType: DiaperType = .pee
    @State private var pooAmount: PooAmount = .medium
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Time") {
                    DatePicker("Time", selection: $timestamp, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Type") {
                    Picker("Type", selection: $diaperType) {
                        ForEach(DiaperType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if diaperType.hasPoo {
                    Section("Poo Amount") {
                        Picker("Amount", selection: $pooAmount) {
                            ForEach(PooAmount.allCases, id: \.self) { amount in
                                Text(amount.rawValue).tag(amount)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .onAppear { populateFromEntry() }
            .navigationTitle(isEditing ? "Edit Diaper" : "Log Diaper")
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
        timestamp = entry.timestamp
        diaperType = entry.diaperType
        pooAmount = entry.pooAmount ?? .medium
        notes = entry.notes
    }

    private func save() {
        if let entry = entryToEdit {
            entry.timestamp = timestamp
            entry.diaperType = diaperType
            entry.pooAmount = diaperType.hasPoo ? pooAmount : nil
            entry.notes = notes
        } else {
            let entry = DiaperEntry(timestamp: timestamp, diaperType: diaperType, pooAmount: diaperType.hasPoo ? pooAmount : nil, notes: notes)
            modelContext.insert(entry)
        }
        ReminderManager.reschedule()
        dismiss()
    }
}
