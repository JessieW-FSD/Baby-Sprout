import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FeedingEntry.timestamp, order: .reverse) private var allFeedings: [FeedingEntry]
    @Query(sort: \SleepEntry.startTime, order: .reverse) private var allSleeps: [SleepEntry]
    @Query(sort: \DiaperEntry.timestamp, order: .reverse) private var allDiapers: [DiaperEntry]
    @Query(sort: \SupplementEntry.timestamp, order: .reverse) private var allSupplements: [SupplementEntry]

    @State private var showAddFeeding = false
    @State private var showAddSleep = false
    @State private var showAddDiaper = false
    @State private var showAddSupplement = false

    private var todayFeedings: [FeedingEntry] {
        filterToday(allFeedings, keyPath: \.timestamp)
    }

    private var todaySleeps: [SleepEntry] {
        filterToday(allSleeps, keyPath: \.startTime)
    }

    private var todayDiapers: [DiaperEntry] {
        filterToday(allDiapers, keyPath: \.timestamp)
    }

    private var todaySupplements: [SupplementEntry] {
        filterToday(allSupplements, keyPath: \.timestamp)
    }

    private func filterToday<T>(_ items: [T], keyPath: KeyPath<T, Date>) -> [T] {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return items.filter { $0[keyPath: keyPath] >= startOfDay }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text(Date(), style: .date)
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        SummaryCard(title: "Feedings", count: todayFeedings.count, icon: "cup.and.saucer.fill", color: .blue) {
                            showAddFeeding = true
                        }
                        SummaryCard(title: "Sleep", count: todaySleeps.count, icon: "moon.fill", color: .indigo) {
                            showAddSleep = true
                        }
                        SummaryCard(title: "Diapers", count: todayDiapers.count, icon: "drop.fill", color: .orange) {
                            showAddDiaper = true
                        }
                        SummaryCard(title: "Supplements", count: todaySupplements.count, icon: "pill.fill", color: .green) {
                            showAddSupplement = true
                        }
                    }

                    VStack(spacing: 12) {
                        if let lastFeeding = allFeedings.first {
                            LastEntryCard(title: "Last Feeding", time: lastFeeding.timestamp, detail: lastFeeding.summary)
                        }
                        if let lastSleep = allSleeps.first {
                            LastEntryCard(title: "Last Sleep", time: lastSleep.startTime, detail: lastSleep.isActive ? "Currently sleeping" : lastSleep.durationFormatted)
                        }
                        if let lastDiaper = allDiapers.first {
                            LastEntryCard(title: "Last Diaper", time: lastDiaper.timestamp, detail: lastDiaper.diaperType.rawValue)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("EasyBaby")
            .sheet(isPresented: $showAddFeeding) { AddFeedingView() }
            .sheet(isPresented: $showAddSleep) { AddSleepView() }
            .sheet(isPresented: $showAddDiaper) { AddDiaperView() }
            .sheet(isPresented: $showAddSupplement) { AddSupplementView() }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text("\(count)")
                    .font(.title)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct LastEntryCard: View {
    let title: String
    let time: Date
    let detail: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(detail)
                    .font(.body)
                    .fontWeight(.medium)
            }
            Spacer()
            Text(time, style: .time)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
