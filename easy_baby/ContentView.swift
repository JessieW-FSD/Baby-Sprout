import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
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

#Preview {
    ContentView()
        .modelContainer(for: [
            FeedingEntry.self,
            SleepEntry.self,
            DiaperEntry.self,
            SupplementEntry.self,
            GrowthEntry.self,
        ], inMemory: true)
}
