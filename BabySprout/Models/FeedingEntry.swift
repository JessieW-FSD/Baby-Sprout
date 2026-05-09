import Foundation
import SwiftData

enum FeedingType: String, Codable, CaseIterable {
    case bottle = "Bottle"
    case breast = "Breast"
}

enum BreastSide: String, Codable, CaseIterable {
    case left = "Left"
    case right = "Right"
}

@Model
final class FeedingEntry {
    var timestamp: Date
    var feedingTypeRaw: String
    var amountML: Double?
    var leftDurationMinutes: Int?
    var rightDurationMinutes: Int?
    var firstSideRaw: String?
    var notes: String

    init(timestamp: Date = Date(), feedingType: FeedingType, amountML: Double? = nil, leftDurationMinutes: Int? = nil, rightDurationMinutes: Int? = nil, firstSide: BreastSide? = nil, notes: String = "") {
        self.timestamp = timestamp
        self.feedingTypeRaw = feedingType.rawValue
        self.amountML = amountML
        self.leftDurationMinutes = leftDurationMinutes
        self.rightDurationMinutes = rightDurationMinutes
        self.firstSideRaw = firstSide?.rawValue
        self.notes = notes
    }

    var feedingType: FeedingType {
        get { FeedingType(rawValue: feedingTypeRaw) ?? .bottle }
        set { feedingTypeRaw = newValue.rawValue }
    }

    var firstSide: BreastSide? {
        get {
            guard let firstSideRaw else { return nil }
            return BreastSide(rawValue: firstSideRaw)
        }
        set { firstSideRaw = newValue?.rawValue }
    }

    var summary: String {
        switch feedingType {
        case .bottle:
            if let amount = amountML {
                return "Bottle: \(Int(amount)) mL"
            }
            return "Bottle"
        case .breast:
            var parts: [String] = []
            if let left = leftDurationMinutes { parts.append("L: \(left)min") }
            if let right = rightDurationMinutes { parts.append("R: \(right)min") }
            if let side = firstSide { parts.append("(\(side.rawValue) first)") }
            return "Breast: " + (parts.isEmpty ? "—" : parts.joined(separator: " "))
        }
    }
}
