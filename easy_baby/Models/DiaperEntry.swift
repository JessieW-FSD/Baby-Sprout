import Foundation
import SwiftData

enum DiaperType: String, Codable, CaseIterable {
    case pee = "Pee"
    case poo = "Poo"
    case both = "Both"

    var icon: String {
        switch self {
        case .pee: return "drop.fill"
        case .poo: return "leaf.fill"
        case .both: return "drop.circle.fill"
        }
    }

    var hasPoo: Bool {
        self == .poo || self == .both
    }
}

enum PooAmount: String, Codable, CaseIterable {
    case spot = "Spot"
    case little = "Little"
    case medium = "Medium"
    case lots = "Lots"
    case huge = "HUGE"
}

@Model
final class DiaperEntry {
    var timestamp: Date
    var diaperTypeRaw: String
    var pooAmountRaw: String?
    var notes: String

    init(timestamp: Date = Date(), diaperType: DiaperType, pooAmount: PooAmount? = nil, notes: String = "") {
        self.timestamp = timestamp
        self.diaperTypeRaw = diaperType.rawValue
        self.pooAmountRaw = diaperType.hasPoo ? (pooAmount ?? .medium).rawValue : nil
        self.notes = notes
    }

    var diaperType: DiaperType {
        get { DiaperType(rawValue: diaperTypeRaw) ?? .pee }
        set { diaperTypeRaw = newValue.rawValue }
    }

    var pooAmount: PooAmount? {
        get {
            guard let raw = pooAmountRaw else { return nil }
            return PooAmount(rawValue: raw)
        }
        set { pooAmountRaw = newValue?.rawValue }
    }
}
