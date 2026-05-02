import SwiftUI
import SwiftData

struct AddGrowthView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var weightStr = ""
    @State private var heightStr = ""
    @State private var headStr = ""
    @State private var notes = ""

    private var hasAtLeastOneMeasurement: Bool {
        !weightStr.isEmpty || !heightStr.isEmpty || !headStr.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
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
            .navigationTitle("Log Growth")
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

    private func save() {
        let entry = GrowthEntry(
            date: date,
            weightKg: Double(weightStr),
            heightCm: Double(heightStr),
            headCircumferenceCm: Double(headStr),
            notes: notes
        )
        modelContext.insert(entry)
        dismiss()
    }
}
