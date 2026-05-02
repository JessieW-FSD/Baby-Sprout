import SwiftUI
import SwiftData

struct AddFeedingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var timestamp = Date()
    @State private var feedingType: FeedingType = .bottle
    @State private var amountML: Double = 60
    @State private var leftMinutes: Int = 0
    @State private var rightMinutes: Int = 0
    @State private var firstSide: BreastSide = .left
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Time") {
                    DatePicker("Time", selection: $timestamp, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Type") {
                    Picker("Type", selection: $feedingType) {
                        ForEach(FeedingType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if feedingType == .bottle {
                    Section("Amount") {
                        HStack {
                            Text("\(Int(amountML)) mL")
                                .monospacedDigit()
                            Slider(value: $amountML, in: 10...300, step: 5)
                        }
                    }
                } else {
                    Section("Duration") {
                        Stepper("Left: \(leftMinutes) min", value: $leftMinutes, in: 0...60)
                        Stepper("Right: \(rightMinutes) min", value: $rightMinutes, in: 0...60)
                        Picker("First side", selection: $firstSide) {
                            ForEach(BreastSide.allCases, id: \.self) { side in
                                Text(side.rawValue).tag(side)
                            }
                        }
                    }
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .navigationTitle("Log Feeding")
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
        let entry: FeedingEntry
        switch feedingType {
        case .bottle:
            entry = FeedingEntry(timestamp: timestamp, feedingType: .bottle, amountML: amountML)
        case .breast:
            entry = FeedingEntry(timestamp: timestamp, feedingType: .breast, leftDurationMinutes: leftMinutes, rightDurationMinutes: rightMinutes, firstSide: firstSide)
        }
        entry.notes = notes
        modelContext.insert(entry)
        dismiss()
    }
}
