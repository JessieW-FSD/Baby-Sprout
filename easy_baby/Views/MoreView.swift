import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    SupplementListView()
                } label: {
                    Label("Supplements", systemImage: "pill.fill")
                }

                NavigationLink {
                    GrowthListView()
                } label: {
                    Label("Growth", systemImage: "chart.bar.fill")
                }
            }
            .navigationTitle("More")
        }
    }
}
