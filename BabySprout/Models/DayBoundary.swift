import Foundation

enum DayBoundary {
    static func logicalDay(for date: Date, startHour: Int) -> Date {
        let calendar = Calendar.current
        let adjusted = calendar.date(byAdding: .hour, value: -startHour, to: date) ?? date
        return calendar.startOfDay(for: adjusted)
    }

    static func label(for day: Date, startHour: Int) -> String {
        let calendar = Calendar.current
        let today = logicalDay(for: .now, startHour: startHour)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today

        if calendar.isDate(day, inSameDayAs: today) {
            return "Today"
        } else if calendar.isDate(day, inSameDayAs: yesterday) {
            return "Yesterday"
        } else {
            return day.formatted(.dateTime.weekday(.wide).month().day())
        }
    }

    static func group<T>(_ items: [T], by keyPath: KeyPath<T, Date>, startHour: Int) -> [(day: Date, items: [T])] {
        Dictionary(grouping: items) { item in
            logicalDay(for: item[keyPath: keyPath], startHour: startHour)
        }
        .sorted { $0.key > $1.key }
        .map { (day: $0.key, items: $0.value) }
    }
}
