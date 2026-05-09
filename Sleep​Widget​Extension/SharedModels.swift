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

    init(timestamp: Date = Date(), feedingTypeRaw: String = "Bottle", amountML: Double? = nil, leftDurationMinutes: Int? = nil, rightDurationMinutes: Int? = nil, firstSideRaw: String? = nil, notes: String = "") {
        self.timestamp = timestamp
        self.feedingTypeRaw = feedingTypeRaw
        self.amountML = amountML
        self.leftDurationMinutes = leftDurationMinutes
        self.rightDurationMinutes = rightDurationMinutes
        self.firstSideRaw = firstSideRaw
        self.notes = notes
    }
}

@Model
final class DiaperEntry {
    var timestamp: Date
    var diaperTypeRaw: String
    var pooAmountRaw: String?
    var notes: String

    init(timestamp: Date = Date(), diaperTypeRaw: String = "Pee", pooAmountRaw: String? = nil, notes: String = "") {
        self.timestamp = timestamp
        self.diaperTypeRaw = diaperTypeRaw
        self.pooAmountRaw = pooAmountRaw
        self.notes = notes
    }
}

@Model
final class SupplementEntry {
    var timestamp: Date
    var name: String
    var dosage: String
    var notes: String

    init(timestamp: Date = Date(), name: String = "", dosage: String = "", notes: String = "") {
        self.timestamp = timestamp
        self.name = name
        self.dosage = dosage
        self.notes = notes
    }
}

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
}

@Model
final class CustomEventEntry {
    var timestamp: Date
    var title: String
    var eventDescription: String
    @Attribute(.externalStorage) var photoDataArray: [Data]
    var notes: String

    init(timestamp: Date = Date(), title: String = "", eventDescription: String = "", photoDataArray: [Data] = [], notes: String = "") {
        self.timestamp = timestamp
        self.title = title
        self.eventDescription = eventDescription
        self.photoDataArray = photoDataArray
        self.notes = notes
    }
}

import ActivityKit

struct SleepActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var endTime: Date?
    }
    var sleepStartTime: Date
    var babyName: String
}
