import ActivityKit
import Foundation
import os

private let logger = Logger(subsystem: "dev.fullstackdata.baby-sprout", category: "SleepActivity")

enum SleepActivityManager {
    static func startActivity(startTime: Date) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.notice("Live Activities not enabled — check Settings > BabySprout > Live Activities")
            return
        }

        let babyName = UserDefaults.standard.string(forKey: AppStorageKeys.babyName) ?? "Baby"
        let attributes = SleepActivityAttributes(sleepStartTime: startTime, babyName: babyName)
        let content = ActivityContent(state: SleepActivityAttributes.ContentState(), staleDate: nil)

        do {
            let newActivity = try Activity.request(attributes: attributes, content: content, pushType: nil)
            logger.info("Started activity: \(newActivity.id)")

            Task {
                for activity in Activity<SleepActivityAttributes>.activities where activity.id != newActivity.id {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
            }
        } catch {
            logger.error("Failed to start: \(error.localizedDescription)")
        }
    }

    static func endAllActivities() {
        Task {
            let wakeTime = Date()
            let state = SleepActivityAttributes.ContentState(endTime: wakeTime)
            let content = ActivityContent(state: state, staleDate: nil)
            for activity in Activity<SleepActivityAttributes>.activities {
                await activity.end(content, dismissalPolicy: .immediate)
            }
        }
    }
}
