import WidgetKit
import SwiftUI
import AppIntents
import SwiftData

struct SleepWidgetEntry: TimelineEntry {
    let date: Date
    let isSleeping: Bool
    let sleepStartTime: Date?
}

struct SleepWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SleepWidgetEntry {
        SleepWidgetEntry(date: .now, isSleeping: true, sleepStartTime: .now.addingTimeInterval(-3600))
    }

    func getSnapshot(in context: Context, completion: @escaping (SleepWidgetEntry) -> Void) {
        completion(fetchCurrentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SleepWidgetEntry>) -> Void) {
        let entry = fetchCurrentEntry()
        let refreshDate = entry.isSleeping
            ? Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
            : Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }

    private func fetchCurrentEntry() -> SleepWidgetEntry {
        do {
            let config = ModelConfiguration(
                groupContainer: .identifier("group.fullstackdata.dev.baby-sprout")
            )
            let container = try ModelContainer(
                for: SleepEntry.self, FeedingEntry.self, DiaperEntry.self,
                     SupplementEntry.self, GrowthEntry.self, CustomEventEntry.self,
                configurations: config
            )
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<SleepEntry>(
                predicate: #Predicate { $0.endTime == nil }
            )
            let activeSleeps = try context.fetch(descriptor)
            if let active = activeSleeps.first {
                return SleepWidgetEntry(date: .now, isSleeping: true, sleepStartTime: active.startTime)
            }
        } catch {}
        return SleepWidgetEntry(date: .now, isSleeping: false, sleepStartTime: nil)
    }
}

struct SleepWidgetView: View {
    var entry: SleepWidgetEntry

    var body: some View {
        if entry.isSleeping, let startTime = entry.sleepStartTime {
            VStack(alignment: .leading, spacing: 2) {
                Label("Sleeping", systemImage: "moon.zzz.fill")
                    .font(.headline)
                    .widgetAccentable()
                Text(startTime, style: .timer)
                    .font(.caption)
                    .contentTransition(.numericText())
                Button(intent: StopSleepIntent()) {
                    Label("Wake", systemImage: "sun.max.fill")
                        .font(.caption2)
                }
            }
        } else {
            VStack(spacing: 4) {
                Image(systemName: "sun.max.fill")
                    .font(.title3)
                Text("Awake")
                    .font(.headline)
            }
        }
    }
}

struct SleepWidget: Widget {
    let kind = "SleepWidget"

    private var supportedFamilies: [WidgetFamily] {
        #if os(iOS)
        [.accessoryRectangular]
        #else
        [.systemSmall]
        #endif
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SleepWidgetProvider()) { entry in
            SleepWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Sleep Tracker")
        .description("See when your baby is sleeping and stop the timer.")
        .supportedFamilies(supportedFamilies)
    }
}

@main
struct SleepWidgetBundle: WidgetBundle {
    var body: some Widget {
        SleepWidget()
        SleepLiveActivity()
    }
}
