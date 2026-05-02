import SwiftUI
import SwiftData

struct AddSupplementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

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
            .navigationTitle("Log Supplement")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.isEmpty)
                }
            }
        }
    }

    private func save() {
        let entry = SupplementEntry(timestamp: timestamp, name: name, dosage: dosage, notes: notes)
        modelContext.insert(entry)
        dismiss()
    }
}
