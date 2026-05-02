import Foundation
import SwiftData

@Model
final class GrowthEntry {
    var date: Date
    var weightKg: Double?
    var heightCm: Double?
    var headCircumferenceCm: Double?
    var notes: String

    init(date: Date = Date(), weightKg: Double? = nil, heightCm: Double? = nil, headCircumferenceCm: Double? = nil, notes: String = "") {
        self.date = date
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.headCircumferenceCm = headCircumferenceCm
        self.notes = notes
    }

    var summary: String {
        var parts: [String] = []
        if let w = weightKg { parts.append(String(format: "%.1f kg", w)) }
        if let h = heightCm { parts.append(String(format: "%.1f cm", h)) }
        if let hc = headCircumferenceCm { parts.append(String(format: "HC: %.1f cm", hc)) }
        return parts.isEmpty ? "No measurements" : parts.joined(separator: " · ")
    }
}
