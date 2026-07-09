import SwiftUI
import SwiftData
import WidgetKit

@main
struct BabySproutApp: App {
    init() {
        UserDefaults.standard.register(defaults: [AppStorageKeys.reminderEnabled: true])
        ReminderManager.requestPermission()
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FeedingEntry.self,
            SleepEntry.self,
            DiaperEntry.self,
            SupplementEntry.self,
            GrowthEntry.self,
            CustomEventEntry.self,
            FoodEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier(AppGroupConstants.appGroupID)
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
