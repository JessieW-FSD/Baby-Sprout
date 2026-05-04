import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

struct ExportView: View {
    @AppStorage("babyName") private var babyName = ""

    @Query(sort: \FeedingEntry.timestamp, order: .reverse) private var allFeedings: [FeedingEntry]
    @Query(sort: \SleepEntry.startTime, order: .reverse) private var allSleeps: [SleepEntry]
    @Query(sort: \DiaperEntry.timestamp, order: .reverse) private var allDiapers: [DiaperEntry]
    @Query(sort: \SupplementEntry.timestamp, order: .reverse) private var allSupplements: [SupplementEntry]
    @Query(sort: \GrowthEntry.date, order: .reverse) private var allGrowth: [GrowthEntry]

    @State private var fromDate = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: .now) ?? .now)
    @State private var toDate = Date.now
    @State private var includeFeeding = true
    @State private var includeSleep = true
    @State private var includeDiaper = true
    @State private var includeSupplement = true
    @State private var includeGrowth = true

    private var hasSelection: Bool {
        includeFeeding || includeSleep || includeDiaper || includeSupplement || includeGrowth
    }

    private func filteredFeedings() -> [FeedingEntry] {
        guard includeFeeding else { return [] }
        let start = Calendar.current.startOfDay(for: fromDate)
        return allFeedings.filter { $0.timestamp >= start && $0.timestamp <= endOfDay(toDate) }
    }

    private func filteredSleeps() -> [SleepEntry] {
        guard includeSleep else { return [] }
        let start = Calendar.current.startOfDay(for: fromDate)
        return allSleeps.filter { $0.startTime >= start && $0.startTime <= endOfDay(toDate) }
    }

    private func filteredDiapers() -> [DiaperEntry] {
        guard includeDiaper else { return [] }
        let start = Calendar.current.startOfDay(for: fromDate)
        return allDiapers.filter { $0.timestamp >= start && $0.timestamp <= endOfDay(toDate) }
    }

    private func filteredSupplements() -> [SupplementEntry] {
        guard includeSupplement else { return [] }
        let start = Calendar.current.startOfDay(for: fromDate)
        return allSupplements.filter { $0.timestamp >= start && $0.timestamp <= endOfDay(toDate) }
    }

    private func filteredGrowth() -> [GrowthEntry] {
        guard includeGrowth else { return [] }
        let start = Calendar.current.startOfDay(for: fromDate)
        return allGrowth.filter { $0.date >= start && $0.date <= endOfDay(toDate) }
    }

    private func endOfDay(_ date: Date) -> Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date) ?? date
    }

    private var totalEntries: Int {
        filteredFeedings().count + filteredSleeps().count + filteredDiapers().count
            + filteredSupplements().count + filteredGrowth().count
    }

    var body: some View {
        Form {
            Section("Date Range") {
                DatePicker("From", selection: $fromDate, in: ...toDate, displayedComponents: .date)
                DatePicker("To", selection: $toDate, in: fromDate...Date.now, displayedComponents: .date)
            }

            Section("Categories") {
                Toggle("Feeding", isOn: $includeFeeding)
                Toggle("Sleep", isOn: $includeSleep)
                Toggle("Diapers", isOn: $includeDiaper)
                Toggle("Supplements", isOn: $includeSupplement)
                Toggle("Growth", isOn: $includeGrowth)
            }

            Section {
                Text("\(totalEntries) entries in selected range")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Export") {
                Button {
                    exportAs(format: .csv)
                } label: {
                    Label("Export as CSV", systemImage: "tablecells")
                }
                .disabled(!hasSelection || totalEntries == 0)

                Button {
                    exportAs(format: .pdf)
                } label: {
                    Label("Export as PDF", systemImage: "doc.richtext")
                }
                .disabled(!hasSelection || totalEntries == 0)
            }
        }
        .navigationTitle("Export Data")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private enum ExportFormat {
        case csv, pdf
    }

    private func exportAs(format: ExportFormat) {
        let exporter = DataExporter(babyName: babyName, fromDate: fromDate, toDate: toDate)
        let url: URL?
        switch format {
        case .csv:
            url = exporter.generateCSV(
                feedings: filteredFeedings(),
                sleeps: filteredSleeps(),
                diapers: filteredDiapers(),
                supplements: filteredSupplements(),
                growth: filteredGrowth()
            )
        case .pdf:
            url = exporter.generatePDF(
                feedings: filteredFeedings(),
                sleeps: filteredSleeps(),
                diapers: filteredDiapers(),
                supplements: filteredSupplements(),
                growth: filteredGrowth()
            )
        }
        guard let url else { return }
        presentShareSheet(for: url)
    }

    private func presentShareSheet(for url: URL) {
        #if os(iOS)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        var presenter = rootVC
        while let presented = presenter.presentedViewController {
            presenter = presented
        }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = presenter.view
        presenter.present(activityVC, animated: true)
        #endif
    }
}
