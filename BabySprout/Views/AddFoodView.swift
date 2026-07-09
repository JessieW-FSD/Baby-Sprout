import SwiftUI
import SwiftData

struct AddFoodView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var entryToEdit: FoodEntry?
    private var isEditing: Bool { entryToEdit != nil }

    @State private var timestamp = Date()
    @State private var foodName = ""
    @State private var foodCategory: FoodCategory = .puree
    @State private var amountText = ""
    @State private var amountUnit: AmountUnit = .tablespoon
    @State private var reaction: FoodReaction? = nil
    @State private var hasReaction = false
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Time") {
                    DatePicker("Time", selection: $timestamp, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Food") {
                    TextField("Food name (e.g., Sweet Potato)", text: $foodName)
                    Picker("Category", selection: $foodCategory) {
                        ForEach(FoodCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                }

                Section("Amount") {
                    HStack {
                        TextField("Amount", text: $amountText)
                            .keyboardType(.decimalPad)
                            .frame(maxWidth: 100)
                        Spacer()
                        Picker("Unit", selection: $amountUnit) {
                            ForEach(AmountUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                Section("Reaction") {
                    Toggle("Log reaction", isOn: $hasReaction)
                    if hasReaction {
                        Picker("How did baby respond?", selection: Binding(
                            get: { reaction ?? .liked },
                            set: { reaction = $0 }
                        )) {
                            ForEach(FoodReaction.allCases, id: \.self) { r in
                                Text("\(r.icon) \(r.rawValue)").tag(r)
                            }
                        }
                    }
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .onAppear { populateFromEntry() }
            .navigationTitle(isEditing ? "Edit Food" : "Log Food")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(foodName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func populateFromEntry() {
        guard let entry = entryToEdit else { return }
        timestamp = entry.timestamp
        foodName = entry.foodName
        foodCategory = entry.foodCategory
        if let amount = entry.amount {
            amountText = amount.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(amount))
                : String(format: "%.1f", amount)
        }
        amountUnit = entry.amountUnit
        if let r = entry.reaction {
            hasReaction = true
            reaction = r
        }
        notes = entry.notes
    }

    private func save() {
        let parsedAmount = Double(amountText.trimmingCharacters(in: .whitespaces))
        let finalReaction: FoodReaction? = hasReaction ? (reaction ?? .liked) : nil

        if let entry = entryToEdit {
            entry.timestamp = timestamp
            entry.foodName = foodName.trimmingCharacters(in: .whitespaces)
            entry.foodCategory = foodCategory
            entry.amount = parsedAmount
            entry.amountUnit = amountUnit
            entry.reaction = finalReaction
            entry.notes = notes
        } else {
            let entry = FoodEntry(
                timestamp: timestamp,
                foodName: foodName.trimmingCharacters(in: .whitespaces),
                foodCategory: foodCategory,
                amount: parsedAmount,
                amountUnit: amountUnit,
                reaction: finalReaction,
                notes: notes
            )
            modelContext.insert(entry)
        }
        ReminderManager.reschedule()
        dismiss()
    }
}
