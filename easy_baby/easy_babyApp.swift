import SwiftUI
import SwiftData

@main
struct easy_babyApp: App {
    init() {
        UserDefaults.standard.register(defaults: ["reminderEnabled": true])
        ReminderManager.requestPermission()
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FeedingEntry.self,
            SleepEntry.self,
            DiaperEntry.self,
            SupplementEntry.self,
            GrowthEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

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
