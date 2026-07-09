import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FeedingEntry.timestamp, order: .reverse) private var allFeedings: [FeedingEntry]
    @Query(sort: \SleepEntry.startTime, order: .reverse) private var allSleeps: [SleepEntry]
    @Query(sort: \DiaperEntry.timestamp, order: .reverse) private var allDiapers: [DiaperEntry]
    @Query(sort: \SupplementEntry.timestamp, order: .reverse) private var allSupplements: [SupplementEntry]
    @Query(sort: \GrowthEntry.date, order: .reverse) private var allGrowth: [GrowthEntry]
    @Query(sort: \CustomEventEntry.timestamp, order: .reverse) private var allEvents: [CustomEventEntry]
    @Query(sort: \FoodEntry.timestamp, order: .reverse) private var allFoods: [FoodEntry]

    @AppStorage(AppStorageKeys.dayStartHour) private var dayStartHour = 8
    @AppStorage(AppStorageKeys.babyName) private var babyName = ""
    @AppStorage(AppStorageKeys.babyDOB) private var babyDOBTimeInterval: Double = Date.now.timeIntervalSince1970
    @State private var showAddFeeding = false
    @State private var showAddSleep = false
    @State private var showAddDiaper = false
    @State private var showAddSupplement = false
    @State private var showAddGrowth = false
    @State private var showAddEvent = false
    @State private var showAddFood = false
    @State private var sleepToEnd: SleepEntry?

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

    private var todayEvents: [CustomEventEntry] {
        filterToday(allEvents, keyPath: \.timestamp)
    }

    private var todayFoods: [FoodEntry] {
        filterToday(allFoods, keyPath: \.timestamp)
    }

    private func filterToday<T>(_ items: [T], keyPath: KeyPath<T, Date>) -> [T] {
        let today = DayBoundary.logicalDay(for: .now, startHour: dayStartHour)
        return items.filter { DayBoundary.logicalDay(for: $0[keyPath: keyPath], startHour: dayStartHour) == today }
    }

    // MARK: - Feeding Stats

    private var bottleFeedings: [FeedingEntry] {
        todayFeedings.filter { $0.feedingType == .bottle }
    }

    private var breastFeedings: [FeedingEntry] {
        todayFeedings.filter { $0.feedingType == .breast }
    }

    private var totalBottleML: Int {
        Int(bottleFeedings.compactMap(\.amountML).reduce(0, +))
    }

    private var totalLeftMinutes: Int {
        breastFeedings.compactMap(\.leftDurationMinutes).reduce(0, +)
    }

    private var totalRightMinutes: Int {
        breastFeedings.compactMap(\.rightDurationMinutes).reduce(0, +)
    }

    private var totalBreastMinutes: Int {
        totalLeftMinutes + totalRightMinutes
    }

    // MARK: - Sleep Stats

    private var completedSleeps: [SleepEntry] {
        todaySleeps.filter { $0.duration != nil }
    }

    private var totalSleepSeconds: TimeInterval {
        completedSleeps.compactMap(\.duration).reduce(0, +)
    }

    private var avgSleepSeconds: TimeInterval {
        guard !completedSleeps.isEmpty else { return 0 }
        return totalSleepSeconds / Double(completedSleeps.count)
    }

    // MARK: - Diaper Stats

    private var peeCount: Int {
        todayDiapers.filter { $0.diaperType == .pee || $0.diaperType == .both }.count
    }

    private var pooCount: Int {
        todayDiapers.filter { $0.diaperType == .poo || $0.diaperType == .both }.count
    }

    private var lastPeeDate: Date? {
        allDiapers.first(where: { $0.diaperType == .pee || $0.diaperType == .both })?.timestamp
    }

    private var lastPooDate: Date? {
        allDiapers.first(where: { $0.diaperType == .poo || $0.diaperType == .both })?.timestamp
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text(Date(), style: .date)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text(babyAgeDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // MARK: Growth Card
                    if let latest = allGrowth.first {
                        StatCard(title: "Growth", icon: "chart.bar.fill", color: .purple) {
                            showAddGrowth = true
                        } content: {
                            HStack(spacing: 16) {
                                if let weight = latest.weightKg {
                                    CompactStat(label: "Weight", value: String(format: "%.1f kg", weight))
                                }
                                if let height = latest.heightCm {
                                    CompactStat(label: "Height", value: String(format: "%.1f cm", height))
                                }
                                if let head = latest.headCircumferenceCm {
                                    CompactStat(label: "Head", value: String(format: "%.1f cm", head))
                                }
                                Spacer()
                                Text(latest.date.formatted(.dateTime.month().day()))
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }

                    // MARK: Feeding + Food
                    HStack(spacing: 12) {
                        StatCard(title: "Feeding", icon: "cup.and.saucer.fill", color: .blue, lastEventDate: allFeedings.first?.timestamp) {
                            showAddFeeding = true
                        } content: {
                            CompactStat(label: "Sessions", value: "\(todayFeedings.count)")
                            if bottleFeedings.isEmpty && breastFeedings.isEmpty {
                                CompactStat(label: "Bottle", value: "--")
                                CompactStat(label: "Breast", value: "--")
                            } else if breastFeedings.isEmpty {
                                CompactStat(label: "Total", value: "\(totalBottleML) mL")
                            } else if bottleFeedings.isEmpty {
                                CompactStat(label: "L / R", value: "\(formatMinutes(totalLeftMinutes)) / \(formatMinutes(totalRightMinutes))")
                            } else {
                                CompactStat(label: "Bottle", value: "\(totalBottleML) mL")
                                CompactStat(label: "Breast", value: formatMinutes(totalBreastMinutes))
                            }
                        }
                        .frame(maxHeight: .infinity)

                        StatCard(title: "Food", icon: "fork.knife", color: .orange, lastEventDate: allFoods.first?.timestamp) {
                            showAddFood = true
                        } content: {
                            CompactStat(label: "Logged today", value: "\(todayFoods.count)")
                            if let last = allFoods.first {
                                CompactStat(label: "Last", value: last.foodName)
                            }
                        }
                        .frame(maxHeight: .infinity)
                    }

                    // MARK: Sleep Card
                    StatCard(title: "Sleep", icon: "moon.fill", color: .indigo, lastEventDate: allSleeps.first(where: { $0.endTime != nil })?.endTime) {
                        showAddSleep = true
                    } content: {
                        HStack(spacing: 16) {
                            CompactStat(label: "Sessions", value: "\(todaySleeps.count)")
                            if !completedSleeps.isEmpty {
                                CompactStat(label: "Total", value: formatDuration(totalSleepSeconds))
                                CompactStat(label: "Avg", value: formatDuration(avgSleepSeconds))
                            }
                            Spacer()
                        }
                        if let activeSleep = todaySleeps.first(where: \.isActive) {
                            Button {
                                sleepToEnd = activeSleep
                            } label: {
                                HStack {
                                    Image(systemName: "moon.zzz.fill")
                                    Text("Baby is sleeping")
                                    Spacer()
                                    Text("End Sleep")
                                        .fontWeight(.semibold)
                                    Image(systemName: "chevron.right")
                                }
                                .font(.subheadline)
                                .padding(10)
                                .background(.indigo.opacity(0.15))
                                .foregroundStyle(.indigo)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // MARK: Supplements + Diapers
                    HStack(spacing: 12) {
                        StatCard(title: "Supplements", icon: "pill.fill", color: .green) {
                            showAddSupplement = true
                        } content: {
                            CompactStat(label: "Logged today", value: "\(todaySupplements.count)")
                        }
                        .frame(maxHeight: .infinity)

                        StatCard(title: "Diapers", icon: "drop.fill", color: .yellow, lastEventDate: allDiapers.first?.timestamp) {
                            showAddDiaper = true
                        } content: {
                            CompactStat(label: "Total", value: "\(todayDiapers.count)")
                            TimelineView(.periodic(from: .now, by: 60)) { context in
                                VStack(alignment: .leading) {
                                    CompactStat(label: "Pee" + (lastPeeDate.map { " · \(timeSince(from: $0, to: context.date))" } ?? ""), value: "\(peeCount)")
                                    CompactStat(label: "Poo" + (lastPooDate.map { " · \(timeSince(from: $0, to: context.date))" } ?? ""), value: "\(pooCount)")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxHeight: .infinity)
                    }

                    // MARK: Events
                    StatCard(title: "Events", icon: "note.text", color: .red) {
                        showAddEvent = true
                    } content: {
                        CompactStat(label: "Logged today", value: "\(todayEvents.count)")
                    }

                    // MARK: Last Entries
                    VStack(spacing: 12) {
                        if let lastFeeding = allFeedings.first {
                            LastEntryCard(title: "Last Feeding", time: lastFeeding.timestamp, detail: lastFeeding.summary)
                        }
                        if let lastFood = allFoods.first {
                            LastEntryCard(title: "Last Food", time: lastFood.timestamp, detail: "\(lastFood.foodName) · \(lastFood.summary)")
                        }
                        if let lastSleep = allSleeps.first {
                            LastEntryCard(title: "Last Sleep", time: lastSleep.startTime, detail: lastSleep.isActive ? "Currently sleeping" : lastSleep.durationFormatted)
                        }
                        if let lastDiaper = allDiapers.first {
                            LastEntryCard(title: "Last Diaper", time: lastDiaper.timestamp, detail: lastDiaper.diaperType.rawValue)
                        }
                        if let lastEvent = allEvents.first {
                            LastEntryCard(title: "Last Event", time: lastEvent.timestamp, detail: lastEvent.summary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(babyName)
            .sheet(isPresented: $showAddFeeding) { AddFeedingView() }
            .sheet(isPresented: $showAddSleep) { AddSleepView() }
            .sheet(isPresented: $showAddDiaper) { AddDiaperView() }
            .sheet(isPresented: $showAddSupplement) { AddSupplementView() }
            .sheet(isPresented: $showAddGrowth) { AddGrowthView() }
            .sheet(isPresented: $showAddEvent) { AddCustomEventView() }
            .sheet(isPresented: $showAddFood) { AddFoodView() }
            .sheet(item: $sleepToEnd) { entry in
                EndSleepView(entry: entry)
            }
        }
    }

    private var babyDOB: Date {
        Date(timeIntervalSince1970: babyDOBTimeInterval)
    }

    private var babyAgeDescription: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: babyDOB, to: .now)
        let months = components.month ?? 0
        let days = components.day ?? 0
        if months == 0 {
            return "Day \(days)"
        }
        return "\(months) month\(months == 1 ? "" : "s"), \(days) day\(days == 1 ? "" : "s") old"
    }

    private func formatMinutes(_ totalMinutes: Int) -> String {
        let hours = totalMinutes / 60
        let mins = totalMinutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let mins = (Int(seconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }
}

// MARK: - Stat Card

struct StatCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    var lastEventDate: Date? = nil
    let action: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Button {
                    action()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(color)
                }
            }
            if let date = lastEventDate {
                TimelineView(.periodic(from: .now, by: 60)) { context in
                    Text("Last: \(timeSince(from: date, to: context.date))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            content
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private func timeSince(from: Date, to: Date) -> String {
    let seconds = Int(to.timeIntervalSince(from))
    guard seconds >= 60 else { return "just now" }
    let days = seconds / 86400
    let hours = (seconds % 86400) / 3600
    let minutes = (seconds % 3600) / 60
    if days > 0 {
        return "\(days)d \(hours)h ago"
    }
    if hours > 0 {
        return "\(hours)h \(minutes)m ago"
    }
    return "\(minutes)m ago"
}


struct CompactStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
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
