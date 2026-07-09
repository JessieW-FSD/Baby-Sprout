import AppIntents
import SwiftData
import WidgetKit

struct StopSleepIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Sleep"
    static var description: IntentDescription = "Marks the current sleep session as ended"

    func perform() async throws -> some IntentResult {
        let wakeTime = Date()
        do {
            let config = ModelConfiguration(
                groupContainer: .identifier("group.fullstackdata.dev.baby-sprout")
            )
            let container = try ModelContainer(
                for: SleepEntry.self, FeedingEntry.self, DiaperEntry.self,
                     SupplementEntry.self, GrowthEntry.self, CustomEventEntry.self,
                     FoodEntry.self,
                configurations: config
            )
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<SleepEntry>(
                predicate: #Predicate { $0.endTime == nil }
            )
            let activeSleeps = try context.fetch(descriptor)
            for sleep in activeSleeps {
                sleep.endTime = wakeTime
            }
            try context.save()
        } catch {}

        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
