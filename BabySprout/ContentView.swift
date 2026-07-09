import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage(AppStorageKeys.babyName) private var babyName = ""

    var body: some View {
        if babyName.isEmpty {
            OnboardingView()
        } else {
            TabView {
                DashboardView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                FeedingListView()
                    .tabItem {
                        Label("Feed", systemImage: "cup.and.saucer.fill")
                    }

                SleepListView()
                    .tabItem {
                        Label("Sleep", systemImage: "moon.fill")
                    }

                DiaperListView()
                    .tabItem {
                        Label("Diaper", systemImage: "drop.fill")
                    }

                MoreView()
                    .tabItem {
                        Label("More", systemImage: "ellipsis.circle.fill")
                    }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            FeedingEntry.self,
            SleepEntry.self,
            DiaperEntry.self,
            SupplementEntry.self,
            GrowthEntry.self,
            CustomEventEntry.self,
            FoodEntry.self,
        ], inMemory: true)
}
