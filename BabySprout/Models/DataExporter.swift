import Foundation
#if canImport(UIKit)
import UIKit
#endif

struct DataExporter {
    let babyName: String
    let fromDate: Date
    let toDate: Date

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f
    }

    private var dayFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }

    static func cleanUpExportFiles() {
        let tempDir = FileManager.default.temporaryDirectory
        guard let files = try? FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil) else { return }
        for file in files where file.lastPathComponent.contains("_report_") {
            try? FileManager.default.removeItem(at: file)
        }
    }

    // MARK: - CSV

    func feedingCSV(_ entries: [FeedingEntry]) -> String {
        var lines = ["Date,Time,Type,Amount (mL),Left (min),Right (min),First Side,Notes"]
        for e in entries {
            let date = dayFormatter.string(from: e.timestamp)
            let time = DateFormatter.localizedString(from: e.timestamp, dateStyle: .none, timeStyle: .short)
            let type = e.feedingType.rawValue
            let ml = e.amountML.map { "\(Int($0))" } ?? ""
            let left = e.leftDurationMinutes.map { "\($0)" } ?? ""
            let right = e.rightDurationMinutes.map { "\($0)" } ?? ""
            let side = e.firstSide?.rawValue ?? ""
            let notes = csvEscape(e.notes)
            lines.append("\(date),\(time),\(type),\(ml),\(left),\(right),\(side),\(notes)")
        }
        return lines.joined(separator: "\n")
    }

    func sleepCSV(_ entries: [SleepEntry]) -> String {
        var lines = ["Date,Start Time,End Time,Duration (min),Notes"]
        for e in entries {
            let date = dayFormatter.string(from: e.startTime)
            let start = DateFormatter.localizedString(from: e.startTime, dateStyle: .none, timeStyle: .short)
            let end = e.endTime.map { DateFormatter.localizedString(from: $0, dateStyle: .none, timeStyle: .short) } ?? "Active"
            let dur = e.duration.map { "\(Int($0 / 60))" } ?? ""
            let notes = csvEscape(e.notes)
            lines.append("\(date),\(start),\(end),\(dur),\(notes)")
        }
        return lines.joined(separator: "\n")
    }

    func diaperCSV(_ entries: [DiaperEntry]) -> String {
        var lines = ["Date,Time,Type,Poo Amount,Notes"]
        for e in entries {
            let date = dayFormatter.string(from: e.timestamp)
            let time = DateFormatter.localizedString(from: e.timestamp, dateStyle: .none, timeStyle: .short)
            let type = e.diaperType.rawValue
            let poo = e.pooAmount?.rawValue ?? ""
            let notes = csvEscape(e.notes)
            lines.append("\(date),\(time),\(type),\(poo),\(notes)")
        }
        return lines.joined(separator: "\n")
    }

    func supplementCSV(_ entries: [SupplementEntry]) -> String {
        var lines = ["Date,Time,Name,Dosage,Notes"]
        for e in entries {
            let date = dayFormatter.string(from: e.timestamp)
            let time = DateFormatter.localizedString(from: e.timestamp, dateStyle: .none, timeStyle: .short)
            let notes = csvEscape(e.notes)
            lines.append("\(date),\(time),\(csvEscape(e.name)),\(csvEscape(e.dosage)),\(notes)")
        }
        return lines.joined(separator: "\n")
    }

    func foodCSV(_ entries: [FoodEntry]) -> String {
        var lines = ["Date,Time,Food Name,Category,Amount,Unit,Reaction,Notes"]
        for e in entries {
            let date = dayFormatter.string(from: e.timestamp)
            let time = DateFormatter.localizedString(from: e.timestamp, dateStyle: .none, timeStyle: .short)
            let amount = e.amount.map { $0.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int($0))" : String(format: "%.1f", $0) } ?? ""
            let unit = e.amount != nil ? e.amountUnit.rawValue : ""
            let reaction = e.reaction?.rawValue ?? ""
            lines.append("\(date),\(time),\(csvEscape(e.foodName)),\(e.foodCategory.rawValue),\(amount),\(unit),\(reaction),\(csvEscape(e.notes))")
        }
        return lines.joined(separator: "\n")
    }

    func customEventCSV(_ entries: [CustomEventEntry]) -> String {
        var lines = ["Date,Time,Title,Description,Photos,Notes"]
        for e in entries {
            let date = dayFormatter.string(from: e.timestamp)
            let time = DateFormatter.localizedString(from: e.timestamp, dateStyle: .none, timeStyle: .short)
            let photos = e.photoCount > 0 ? "\(e.photoCount) photo(s)" : ""
            lines.append("\(date),\(time),\(csvEscape(e.title)),\(csvEscape(e.eventDescription)),\(photos),\(csvEscape(e.notes))")
        }
        return lines.joined(separator: "\n")
    }

    func growthCSV(_ entries: [GrowthEntry]) -> String {
        var lines = ["Date,Weight (kg),Height (cm),Head Circumference (cm),Notes"]
        for e in entries {
            let date = dayFormatter.string(from: e.date)
            let w = e.weightKg.map { String(format: "%.1f", $0) } ?? ""
            let h = e.heightCm.map { String(format: "%.1f", $0) } ?? ""
            let hc = e.headCircumferenceCm.map { String(format: "%.1f", $0) } ?? ""
            let notes = csvEscape(e.notes)
            lines.append("\(date),\(w),\(h),\(hc),\(notes)")
        }
        return lines.joined(separator: "\n")
    }

    func generateCSV(
        feedings: [FeedingEntry],
        sleeps: [SleepEntry],
        diapers: [DiaperEntry],
        supplements: [SupplementEntry],
        growth: [GrowthEntry],
        customEvents: [CustomEventEntry] = [],
        foods: [FoodEntry] = []
    ) throws -> URL? {
        DataExporter.cleanUpExportFiles()

        var sections: [String] = []
        if !feedings.isEmpty { sections.append("=== FEEDING ===\n" + feedingCSV(feedings)) }
        if !foods.isEmpty { sections.append("=== FOOD ===\n" + foodCSV(foods)) }
        if !sleeps.isEmpty { sections.append("=== SLEEP ===\n" + sleepCSV(sleeps)) }
        if !diapers.isEmpty { sections.append("=== DIAPERS ===\n" + diaperCSV(diapers)) }
        if !supplements.isEmpty { sections.append("=== SUPPLEMENTS ===\n" + supplementCSV(supplements)) }
        if !growth.isEmpty { sections.append("=== GROWTH ===\n" + growthCSV(growth)) }
        if !customEvents.isEmpty { sections.append("=== EVENTS ===\n" + customEventCSV(customEvents)) }
        guard !sections.isEmpty else { return nil }

        let content = sections.joined(separator: "\n\n")
        let fileName = "\(babyName)_report_\(dayFormatter.string(from: fromDate))_to_\(dayFormatter.string(from: toDate)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try content.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    // MARK: - PDF

    func generatePDF(
        feedings: [FeedingEntry],
        sleeps: [SleepEntry],
        diapers: [DiaperEntry],
        supplements: [SupplementEntry],
        growth: [GrowthEntry],
        customEvents: [CustomEventEntry] = [],
        foods: [FoodEntry] = []
    ) throws -> URL? {
        #if canImport(UIKit)
        DataExporter.cleanUpExportFiles()

        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 40
        let contentWidth = pageWidth - margin * 2

        let titleFont = UIFont.boldSystemFont(ofSize: 18)
        let headingFont = UIFont.boldSystemFont(ofSize: 14)
        let bodyFont = UIFont.systemFont(ofSize: 10)
        let bodyBold = UIFont.boldSystemFont(ofSize: 10)

        let dateRange = "\(dayFormatter.string(from: fromDate)) to \(dayFormatter.string(from: toDate))"

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let data = renderer.pdfData { context in
            var y: CGFloat = 0

            func newPage() {
                context.beginPage()
                y = margin
            }

            func checkPage(needed: CGFloat) {
                if y + needed > pageHeight - margin {
                    newPage()
                }
            }

            func drawText(_ text: String, font: UIFont, x: CGFloat = margin, maxWidth: CGFloat? = nil) {
                let w = maxWidth ?? contentWidth
                let attr: [NSAttributedString.Key: Any] = [.font: font]
                let boundingRect = (text as NSString).boundingRect(with: CGSize(width: w, height: 1000), options: .usesLineFragmentOrigin, attributes: attr, context: nil)
                checkPage(needed: boundingRect.height + 4)
                (text as NSString).draw(in: CGRect(x: x, y: y, width: w, height: boundingRect.height), withAttributes: attr)
                y += boundingRect.height + 4
            }

            func drawRow(_ cols: [String], widths: [CGFloat], font: UIFont = bodyFont) {
                let rowHeight: CGFloat = 14
                checkPage(needed: rowHeight)
                var x = margin
                for (i, col) in cols.enumerated() {
                    let w = i < widths.count ? widths[i] : 80
                    (col as NSString).draw(in: CGRect(x: x, y: y, width: w, height: rowHeight), withAttributes: [.font: font])
                    x += w
                }
                y += rowHeight
            }

            newPage()

            drawText("\(babyName) — Baby Report", font: titleFont)
            drawText("Period: \(dateRange)", font: bodyFont)
            y += 10

            if !feedings.isEmpty {
                drawText("Feeding (\(feedings.count) entries)", font: headingFont)
                let widths: [CGFloat] = [90, 50, 50, 60, 50, 50, contentWidth - 350]
                drawRow(["Date", "Time", "Type", "mL", "Left", "Right", "Notes"], widths: widths, font: bodyBold)
                for e in feedings {
                    let date = dayFormatter.string(from: e.timestamp)
                    let time = DateFormatter.localizedString(from: e.timestamp, dateStyle: .none, timeStyle: .short)
                    let ml = e.amountML.map { "\(Int($0))" } ?? "-"
                    let left = e.leftDurationMinutes.map { "\($0)m" } ?? "-"
                    let right = e.rightDurationMinutes.map { "\($0)m" } ?? "-"
                    drawRow([date, time, e.feedingType.rawValue, ml, left, right, e.notes], widths: widths)
                }
                y += 10
            }

            if !foods.isEmpty {
                drawText("Food (\(foods.count) entries)", font: headingFont)
                let foodWidths: [CGFloat] = [90, 50, 100, 60, 40, 50, 60, contentWidth - 450]
                drawRow(["Date", "Time", "Food", "Category", "Amt", "Unit", "Reaction", "Notes"], widths: foodWidths, font: bodyBold)
                for e in foods {
                    let date = dayFormatter.string(from: e.timestamp)
                    let time = DateFormatter.localizedString(from: e.timestamp, dateStyle: .none, timeStyle: .short)
                    let amount = e.amount.map { $0.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int($0))" : String(format: "%.1f", $0) } ?? "-"
                    let unit = e.amount != nil ? e.amountUnit.rawValue : "-"
                    let reaction = e.reaction?.rawValue ?? "-"
                    drawRow([date, time, e.foodName, e.foodCategory.rawValue, amount, unit, reaction, e.notes], widths: foodWidths)
                }
                y += 10
            }

            if !sleeps.isEmpty {
                drawText("Sleep (\(sleeps.count) entries)", font: headingFont)
                let widths: [CGFloat] = [90, 60, 60, 70, contentWidth - 280]
                drawRow(["Date", "Start", "End", "Duration", "Notes"], widths: widths, font: bodyBold)
                for e in sleeps {
                    let date = dayFormatter.string(from: e.startTime)
                    let start = DateFormatter.localizedString(from: e.startTime, dateStyle: .none, timeStyle: .short)
                    let end = e.endTime.map { DateFormatter.localizedString(from: $0, dateStyle: .none, timeStyle: .short) } ?? "Active"
                    let dur = e.durationFormatted
                    drawRow([date, start, end, dur, e.notes], widths: widths)
                }
                y += 10
            }

            if !diapers.isEmpty {
                drawText("Diapers (\(diapers.count) entries)", font: headingFont)
                let widths: [CGFloat] = [90, 60, 50, 70, contentWidth - 270]
                drawRow(["Date", "Time", "Type", "Poo Amt", "Notes"], widths: widths, font: bodyBold)
                for e in diapers {
                    let date = dayFormatter.string(from: e.timestamp)
                    let time = DateFormatter.localizedString(from: e.timestamp, dateStyle: .none, timeStyle: .short)
                    let poo = e.pooAmount?.rawValue ?? "-"
                    drawRow([date, time, e.diaperType.rawValue, poo, e.notes], widths: widths)
                }
                y += 10
            }

            if !supplements.isEmpty {
                drawText("Supplements (\(supplements.count) entries)", font: headingFont)
                let widths: [CGFloat] = [90, 60, 100, 80, contentWidth - 330]
                drawRow(["Date", "Time", "Name", "Dosage", "Notes"], widths: widths, font: bodyBold)
                for e in supplements {
                    let date = dayFormatter.string(from: e.timestamp)
                    let time = DateFormatter.localizedString(from: e.timestamp, dateStyle: .none, timeStyle: .short)
                    drawRow([date, time, e.name, e.dosage, e.notes], widths: widths)
                }
                y += 10
            }

            if !growth.isEmpty {
                drawText("Growth (\(growth.count) entries)", font: headingFont)
                let widths: [CGFloat] = [90, 80, 80, 80, contentWidth - 330]
                drawRow(["Date", "Weight", "Height", "Head", "Notes"], widths: widths, font: bodyBold)
                for e in growth {
                    let date = dayFormatter.string(from: e.date)
                    let w = e.weightKg.map { String(format: "%.1f kg", $0) } ?? "-"
                    let h = e.heightCm.map { String(format: "%.1f cm", $0) } ?? "-"
                    let hc = e.headCircumferenceCm.map { String(format: "%.1f cm", $0) } ?? "-"
                    drawRow([date, w, h, hc, e.notes], widths: widths)
                }
                y += 10
            }

            if !customEvents.isEmpty {
                drawText("Events (\(customEvents.count) entries)", font: headingFont)
                let widths: [CGFloat] = [90, 60, 100, contentWidth - 250]
                drawRow(["Date", "Time", "Title", "Description"], widths: widths, font: bodyBold)
                for e in customEvents {
                    let date = dayFormatter.string(from: e.timestamp)
                    let time = DateFormatter.localizedString(from: e.timestamp, dateStyle: .none, timeStyle: .short)
                    let desc = e.eventDescription.isEmpty ? e.notes : e.eventDescription
                    drawRow([date, time, e.title, desc], widths: widths)
                }
            }
        }

        let fileName = "\(babyName)_report_\(dayFormatter.string(from: fromDate))_to_\(dayFormatter.string(from: toDate)).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try data.write(to: url)
        return url
        #else
        return nil
        #endif
    }

    private func csvEscape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }
}
