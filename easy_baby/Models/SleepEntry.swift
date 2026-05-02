import Foundation
import SwiftData

@Model
final class SleepEntry {
    var startTime: Date
    var endTime: Date?
    var notes: String

    init(startTime: Date = Date(), endTime: Date? = nil, notes: String = "") {
        self.startTime = startTime
        self.endTime = endTime
        self.notes = notes
    }

    var isActive: Bool {
        endTime == nil
    }

    var duration: TimeInterval? {
        guard let endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }

    var durationFormatted: String {
        guard let duration else { return "Sleeping..." }
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}
