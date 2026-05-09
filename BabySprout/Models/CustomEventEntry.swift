import Foundation
import SwiftData

@Model
final class CustomEventEntry {
    var timestamp: Date
    var title: String
    var eventDescription: String
    @Attribute(.externalStorage) var photoDataArray: [Data]
    var notes: String

    init(timestamp: Date = Date(), title: String, eventDescription: String = "", photoDataArray: [Data] = [], notes: String = "") {
        self.timestamp = timestamp
        self.title = title
        self.eventDescription = eventDescription
        self.photoDataArray = photoDataArray
        self.notes = notes
    }

    var summary: String {
        if eventDescription.isEmpty {
            return title
        }
        return "\(title) — \(eventDescription)"
    }

    var photoCount: Int {
        photoDataArray.count
    }
}
