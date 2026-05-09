import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

struct SleepLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SleepActivityAttributes.self) { context in
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let endTime = context.state.endTime {
                        Label("\(context.attributes.babyName) is awake", systemImage: "sun.max.fill")
                            .font(.headline)
                        Text(Self.formatDuration(from: context.attributes.sleepStartTime, to: endTime))
                            .font(.title2)
                            .monospacedDigit()
                    } else {
                        Label("\(context.attributes.babyName) is sleeping", systemImage: "moon.zzz.fill")
                            .font(.headline)
                        Text(context.attributes.sleepStartTime, style: .timer)
                            .font(.title2)
                            .monospacedDigit()
                    }
                }
                Spacer()
                if context.state.endTime == nil {
                    Button(intent: StopSleepIntent()) {
                        Label("Wake", systemImage: "sun.max.fill")
                            .font(.body.bold())
                    }
                    .tint(.orange)
                }
            }
            .padding()
            .activityBackgroundTint(.indigo.opacity(0.2))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    if context.state.endTime != nil {
                        Label("Awake", systemImage: "sun.max.fill")
                            .font(.caption)
                    } else {
                        Label("Sleeping", systemImage: "moon.zzz.fill")
                            .font(.caption)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if let endTime = context.state.endTime {
                        Text(Self.formatDuration(from: context.attributes.sleepStartTime, to: endTime))
                            .monospacedDigit()
                            .font(.caption)
                    } else {
                        Text(context.attributes.sleepStartTime, style: .timer)
                            .monospacedDigit()
                            .font(.caption)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.endTime == nil {
                        Button(intent: StopSleepIntent()) {
                            Label("Wake", systemImage: "sun.max.fill")
                        }
                        .tint(.orange)
                    }
                }
            } compactLeading: {
                if context.state.endTime != nil {
                    Image(systemName: "sun.max.fill")
                } else {
                    Image(systemName: "moon.zzz.fill")
                }
            } compactTrailing: {
                if let endTime = context.state.endTime {
                    Text(Self.formatDuration(from: context.attributes.sleepStartTime, to: endTime))
                        .monospacedDigit()
                } else {
                    Text(context.attributes.sleepStartTime, style: .timer)
                        .monospacedDigit()
                }
            } minimal: {
                if context.state.endTime != nil {
                    Image(systemName: "sun.max.fill")
                } else {
                    Image(systemName: "moon.zzz.fill")
                }
            }
        }
    }

    static func formatDuration(from start: Date, to end: Date) -> String {
        let seconds = Int(end.timeIntervalSince(start))
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}
