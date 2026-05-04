import SwiftUI
import SwiftData

struct AddFeedingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \FeedingEntry.timestamp, order: .reverse) private var allFeedings: [FeedingEntry]
    @Query(sort: \SupplementEntry.timestamp, order: .reverse) private var allSupplements: [SupplementEntry]

    var entryToEdit: FeedingEntry?
    private var isEditing: Bool { entryToEdit != nil }

    @State private var timestamp = Date()
    @State private var feedingType: FeedingType = .bottle
    @State private var amountML: Double = 60
    @State private var leftMinutesStr = ""
    @State private var rightMinutesStr = ""
    @State private var firstSide: BreastSide = .left
    @State private var hasAppliedDefault = false
    @State private var selectedSupplements: Set<String> = []
    @State private var newSupplementName = ""
    @State private var notes = ""
    @State private var includeDiaper = false
    @State private var diaperType: DiaperType = .pee
    @State private var pooAmount: PooAmount = .medium

    private var knownSupplementNames: [String] {
        var seen = Set<String>()
        return allSupplements.compactMap { entry in
            let name = entry.name
            guard !seen.contains(name) else { return nil }
            seen.insert(name)
            return name
        }
    }

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
                    Section("Duration (minutes)") {
                        HStack {
                            Text("Left")
                            TextField("0", text: $leftMinutesStr)
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                                .multilineTextAlignment(.trailing)
                            Text("min")
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Right")
                            TextField("0", text: $rightMinutesStr)
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                                .multilineTextAlignment(.trailing)
                            Text("min")
                                .foregroundStyle(.secondary)
                        }
                        Picker("First side", selection: $firstSide) {
                            ForEach(BreastSide.allCases, id: \.self) { side in
                                Text(side.rawValue).tag(side)
                            }
                        }
                    }
                }

                if !isEditing {
                    Section {
                        Toggle("Diaper Change", isOn: $includeDiaper)
                        if includeDiaper {
                            Picker("Diaper Type", selection: $diaperType) {
                                ForEach(DiaperType.allCases, id: \.self) { type in
                                    Label(type.rawValue, systemImage: type.icon).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                            if diaperType.hasPoo {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Poo Amount")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Picker("Poo Amount", selection: $pooAmount) {
                                        ForEach(PooAmount.allCases, id: \.self) { amount in
                                            Text(amount.rawValue).tag(amount)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }
                            }
                        }
                    } header: {
                        Text("Diaper")
                    } footer: {
                        if !includeDiaper {
                            Text("Toggle on to log a diaper change with this feeding")
                        }
                    }

                    Section("Supplements") {
                        ForEach(knownSupplementNames, id: \.self) { name in
                            Toggle(name, isOn: Binding(
                                get: { selectedSupplements.contains(name) },
                                set: { isOn in
                                    if isOn { selectedSupplements.insert(name) }
                                    else { selectedSupplements.remove(name) }
                                }
                            ))
                        }
                        HStack {
                            TextField("Add new supplement", text: $newSupplementName)
                            Button {
                                let name = newSupplementName.trimmingCharacters(in: .whitespaces)
                                guard !name.isEmpty else { return }
                                selectedSupplements.insert(name)
                                newSupplementName = ""
                            } label: {
                                Image(systemName: "plus.circle.fill")
                            }
                            .disabled(newSupplementName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .onAppear { isEditing ? populateFromEntry() : applySmartDefaults() }
            .navigationTitle(isEditing ? "Edit Feeding" : "Log Feeding")
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
        feedingType = entry.feedingType
        amountML = entry.amountML ?? 60
        leftMinutesStr = entry.leftDurationMinutes.map(String.init) ?? ""
        rightMinutesStr = entry.rightDurationMinutes.map(String.init) ?? ""
        firstSide = entry.firstSide ?? .left
        notes = entry.notes
    }

    private func applySmartDefaults() {
        guard !hasAppliedDefault else { return }
        hasAppliedDefault = true
        if let lastFeeding = allFeedings.first {
            feedingType = lastFeeding.feedingType
        }
        if let lastBreast = allFeedings.first(where: { $0.feedingType == .breast }),
           let lastSide = lastBreast.firstSide {
            firstSide = lastSide == .left ? .right : .left
        }
    }

    private func save() {
        if let entry = entryToEdit {
            entry.timestamp = timestamp
            entry.feedingType = feedingType
            switch feedingType {
            case .bottle:
                entry.amountML = amountML
                entry.leftDurationMinutes = nil
                entry.rightDurationMinutes = nil
                entry.firstSide = nil
            case .breast:
                entry.amountML = nil
                entry.leftDurationMinutes = Int(leftMinutesStr)
                entry.rightDurationMinutes = Int(rightMinutesStr)
                entry.firstSide = firstSide
            }
            entry.notes = notes
        } else {
            let entry: FeedingEntry
            switch feedingType {
            case .bottle:
                entry = FeedingEntry(timestamp: timestamp, feedingType: .bottle, amountML: amountML)
            case .breast:
                entry = FeedingEntry(timestamp: timestamp, feedingType: .breast, leftDurationMinutes: Int(leftMinutesStr), rightDurationMinutes: Int(rightMinutesStr), firstSide: firstSide)
            }
            entry.notes = notes
            modelContext.insert(entry)
            if includeDiaper {
                modelContext.insert(DiaperEntry(timestamp: timestamp, diaperType: diaperType, pooAmount: diaperType.hasPoo ? pooAmount : nil))
            }
            for name in selectedSupplements {
                modelContext.insert(SupplementEntry(timestamp: timestamp, name: name))
            }
        }
        ReminderManager.reschedule()
        dismiss()
    }
}
