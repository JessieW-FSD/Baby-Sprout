import SwiftUI
import SwiftData

struct FoodListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodEntry.timestamp, order: .reverse) private var foods: [FoodEntry]
    @AppStorage(AppStorageKeys.dayStartHour) private var dayStartHour = 8
    @State private var showAddSheet = false
    @State private var entryToEdit: FoodEntry?

    private var grouped: [(day: Date, items: [FoodEntry])] {
        DayBoundary.group(foods, by: \.timestamp, startHour: dayStartHour)
    }

    var body: some View {
        List {
            ForEach(grouped, id: \.day) { day, entries in
                Section(DayBoundary.label(for: day, startHour: dayStartHour)) {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(entry.foodName)
                                    .font(.body)
                                    .fontWeight(.medium)
                                Spacer()
                                if let reaction = entry.reaction {
                                    Text(reaction.icon)
                                        .font(.body)
                                }
                            }
                            Text(entry.summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                Text(entry.timestamp, format: .dateTime.hour().minute())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if !entry.notes.isEmpty {
                                    Text("· \(entry.notes)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button("Edit") { entryToEdit = entry }
                                .tint(.blue)
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            modelContext.delete(entries[index])
                        }
                    }
                }
            }
        }
        .navigationTitle("Food")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showAddSheet = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddFoodView()
        }
        .sheet(item: $entryToEdit) { entry in
            AddFoodView(entryToEdit: entry)
        }
        .overlay {
            if foods.isEmpty {
                ContentUnavailableView("No Food Logged", systemImage: "fork.knife", description: Text("Tap + to log a meal or snack"))
            }
        }
    }
}
