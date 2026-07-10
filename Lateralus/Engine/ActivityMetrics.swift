import Foundation

/// A single, documented definition of journal activity used by Today and
/// Insights. Diary entries count toward activity volume and streaks; only the
/// twelve playable challenge types appear in discipline balance.
struct ActivityMetrics {
    struct Entry {
        let date: Date
        let type: ChallengeType
    }

    struct DayCount {
        let day: Date
        let count: Int
    }

    let entries: [Entry]
    let now: Date
    let calendar: Calendar

    init(attempts: [Attempt], now: Date, calendar: Calendar = .autoupdatingCurrent) {
        self.entries = attempts.map { Entry(date: $0.date, type: $0.type) }
        self.now = now
        self.calendar = calendar
    }

    init(entries: [Entry], now: Date, calendar: Calendar) {
        self.entries = entries
        self.now = now
        self.calendar = calendar
    }

    var total: Int { entries.count }

    /// Consecutive active days ending today, or yesterday while today is empty.
    var streak: Int {
        let activeDays = Set(entries.map { calendar.startOfDay(for: $0.date) })
        var cursor = calendar.startOfDay(for: now)
        if !activeDays.contains(cursor) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                return 0
            }
            cursor = yesterday
        }

        var count = 0
        while activeDays.contains(cursor) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }
            cursor = previous
        }
        return count
    }

    /// Entries in the current locale-aware calendar week. Future-dated entries
    /// are excluded even when they fall inside the same week.
    var thisWeek: Int {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: now) else { return 0 }
        return entries.count { interval.contains($0.date) && $0.date <= now }
    }

    var disciplineCounts: [ChallengeType: Int] {
        let playable = Set(ChallengeType.games)
        return Dictionary(grouping: entries.filter { playable.contains($0.type) }, by: \.type)
            .mapValues(\.count)
    }

    /// Entry counts for today and the preceding six local calendar days.
    var lastSevenDays: [DayCount] {
        let byDay = Dictionary(grouping: entries) { calendar.startOfDay(for: $0.date) }
        let today = calendar.startOfDay(for: now)
        return (0..<7).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else {
                return nil
            }
            return DayCount(day: day, count: byDay[day]?.count ?? 0)
        }
    }
}
