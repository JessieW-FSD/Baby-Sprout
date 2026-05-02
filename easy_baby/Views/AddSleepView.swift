import SwiftUI
import SwiftData

struct AddSleepView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var isStillSleeping = false
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Start", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                    Toggle("Still sleeping", isOn: $isStillSleeping)
                    if !isStillSleeping {
                        DatePicker("End", selection: $endTime, in: startTime..., displayedComponents: [.date, .hourAndMinute])
                    }
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .navigationTitle("Log Sleep")
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

    private func save() {
        let entry = SleepEntry(startTime: startTime, endTime: isStillSleeping ? nil : endTime, notes: notes)
        modelContext.insert(entry)
        dismiss()
    }
}
