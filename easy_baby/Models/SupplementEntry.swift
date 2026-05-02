import Foundation
import SwiftData

@Model
final class SupplementEntry {
    var timestamp: Date
    var name: String
    var dosage: String
    var notes: String

    init(timestamp: Date = Date(), name: String, dosage: String = "", notes: String = "") {
        self.timestamp = timestamp
        self.name = name
        self.dosage = dosage
        self.notes = notes
    }

    var summary: String {
        if dosage.isEmpty {
            return name
        }
        return "\(name) — \(dosage)"
    }
}
