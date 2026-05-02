import SwiftUI
import SwiftData

struct DiaperListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DiaperEntry.timestamp, order: .reverse) private var diapers: [DiaperEntry]
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                Section("Quick Add") {
                    HStack(spacing: 12) {
                        ForEach(DiaperType.allCases, id: \.self) { type in
                            Button {
                                quickAdd(type)
                            } label: {
                                VStack {
                                    Image(systemName: type.icon)
                                        .font(.title2)
                                    Text(type.rawValue)
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }

                Section("History") {
                    ForEach(diapers) { entry in
                        HStack {
                            Image(systemName: entry.diaperType.icon)
                                .foregroundStyle(colorForType(entry.diaperType))
                            VStack(alignment: .leading) {
                                Text(entry.diaperType.rawValue)
                                    .font(.body)
                                Text(entry.timestamp, format: .dateTime.month().day().hour().minute())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            if !entry.notes.isEmpty {
                                Spacer()
                                Text(entry.notes)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .onDelete(perform: deleteEntries)
                }
            }
            .navigationTitle("Diapers")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddDiaperView()
            }
        }
    }

    private func quickAdd(_ type: DiaperType) {
        let entry = DiaperEntry(diaperType: type)
        modelContext.insert(entry)
    }

    private func colorForType(_ type: DiaperType) -> Color {
        switch type {
        case .pee: return .yellow
        case .poo: return .brown
        case .both: return .orange
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(diapers[index])
        }
    }
}
