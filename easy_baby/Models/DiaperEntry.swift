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
}

@Model
final class DiaperEntry {
    var timestamp: Date
    var diaperTypeRaw: String
    var notes: String

    init(timestamp: Date = Date(), diaperType: DiaperType, notes: String = "") {
        self.timestamp = timestamp
        self.diaperTypeRaw = diaperType.rawValue
        self.notes = notes
    }

    var diaperType: DiaperType {
        get { DiaperType(rawValue: diaperTypeRaw) ?? .pee }
        set { diaperTypeRaw = newValue.rawValue }
    }
}
