import SwiftUI
import SwiftData

struct AddGrowthView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \GrowthEntry.date, order: .reverse) private var allEntries: [GrowthEntry]

    var entryToEdit: GrowthEntry?
    private var isEditing: Bool { entryToEdit != nil }

    @State private var date = Date()
    @State private var weightStr = ""
    @State private var heightStr = ""
    @State private var headStr = ""
    @State private var notes = ""

    private var hasAtLeastOneMeasurement: Bool {
        !weightStr.isEmpty || !heightStr.isEmpty || !headStr.isEmpty
    }

    private func existingEntry(for selectedDate: Date) -> GrowthEntry? {
        let calendar = Calendar.current
        return allEntries.first { entry in
            entry.persistentModelID != entryToEdit?.persistentModelID
                && calendar.isDate(entry.date, inSameDayAs: selectedDate)
        }
    }

    private var willUpdateExisting: Bool {
        !isEditing && existingEntry(for: date) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                if willUpdateExisting {
                    Section {
                        Label("A measurement already exists for this date. Saving will update it.", systemImage: "info.circle")
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                    }
                }

                Section("Measurements") {
                    HStack {
                        TextField("Weight", text: $weightStr)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                        Text("kg")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        TextField("Height", text: $heightStr)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                        Text("cm")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        TextField("Head circumference", text: $headStr)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                        Text("cm")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .onAppear { populateFromEntry() }
            .navigationTitle(isEditing ? "Edit Growth" : "Log Growth")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!hasAtLeastOneMeasurement)
                }
            }
        }
    }

    private func populateFromEntry() {
        guard let entry = entryToEdit else { return }
        date = entry.date
        weightStr = entry.weightKg.map { String(format: "%.1f", $0) } ?? ""
        heightStr = entry.heightCm.map { String(format: "%.1f", $0) } ?? ""
        headStr = entry.headCircumferenceCm.map { String(format: "%.1f", $0) } ?? ""
        notes = entry.notes
    }

    private func save() {
        let target: GrowthEntry
        if let entry = entryToEdit {
            target = entry
        } else if let existing = existingEntry(for: date) {
            target = existing
        } else {
            target = GrowthEntry(date: date)
            modelContext.insert(target)
        }
        target.date = date
        target.weightKg = Double(weightStr)
        target.heightCm = Double(heightStr)
        target.headCircumferenceCm = Double(headStr)
        target.notes = notes
        ReminderManager.reschedule()
        dismiss()
    }
}
