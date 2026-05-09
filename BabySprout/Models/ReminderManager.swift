import UserNotifications

struct ReminderManager {
    private static let identifier = "easy_baby.activity_reminder"

    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    static func reschedule() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        guard UserDefaults.standard.bool(forKey: AppStorageKeys.reminderEnabled) else { return }

        let babyName = UserDefaults.standard.string(forKey: AppStorageKeys.babyName) ?? "baby"

        let content = UNMutableNotificationContent()
        content.title = "Time to Check In"
        content.body = "It's been 4 hours since you last logged an event for \(babyName)."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 4 * 3600, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }

    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
