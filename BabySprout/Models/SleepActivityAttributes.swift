import ActivityKit
import Foundation

struct SleepActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var endTime: Date?
    }
    var sleepStartTime: Date
    var babyName: String
}
