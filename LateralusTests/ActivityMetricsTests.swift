import Foundation
import Testing
@testable import Lateralus

@MainActor
struct ActivityMetricsTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        calendar.firstWeekday = 1
        return calendar
    }

    @Test func streakIncludesDiaryAndCanEndYesterday() {
        let now = date(2026, 7, 10, hour: 12)
        let metrics = ActivityMetrics(
            entries: [
                entry(2026, 7, 9, type: .diary),
                entry(2026, 7, 8, type: .alternateUse),
                entry(2026, 7, 7, type: .unknown),
            ],
            now: now,
            calendar: calendar
        )

        #expect(metrics.streak == 3)
        #expect(metrics.total == 3)
    }

    @Test func streakStopsAtFirstMissingLocalDay() {
        let metrics = ActivityMetrics(
            entries: [
                entry(2026, 7, 10, type: .diary),
                entry(2026, 7, 8, type: .alternateUse),
            ],
            now: date(2026, 7, 10, hour: 12),
            calendar: calendar
        )

        #expect(metrics.streak == 1)
    }

    @Test func calendarWeekExcludesPriorWeekAndFutureEntries() {
        let metrics = ActivityMetrics(
            entries: [
                entry(2026, 7, 4, type: .diary),
                entry(2026, 7, 9, type: .alternateUse),
                entry(2026, 7, 10, hour: 13, type: .fusion),
            ],
            now: date(2026, 7, 10, hour: 12),
            calendar: calendar
        )

        #expect(metrics.thisWeek == 1)
    }

    @Test func trailingSevenDaysUsesLocalCalendarBoundaries() {
        let metrics = ActivityMetrics(
            entries: [
                entry(2026, 7, 4, type: .diary),
                entry(2026, 7, 10, type: .diary),
                entry(2026, 7, 10, hour: 23, type: .fusion),
            ],
            now: date(2026, 7, 10, hour: 12),
            calendar: calendar
        )

        #expect(metrics.lastSevenDays.map(\.count) == [1, 0, 0, 0, 0, 0, 2])
    }

    @Test func disciplineBalanceExcludesDiaryAndUnknown() {
        let metrics = ActivityMetrics(
            entries: [
                entry(2026, 7, 10, type: .diary),
                entry(2026, 7, 10, type: .unknown),
                entry(2026, 7, 10, type: .fusion),
                entry(2026, 7, 9, type: .fusion),
            ],
            now: date(2026, 7, 10, hour: 12),
            calendar: calendar
        )

        #expect(metrics.disciplineCounts == [.fusion: 2])
    }

    private func entry(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        hour: Int = 12,
        type: ChallengeType
    ) -> ActivityMetrics.Entry {
        ActivityMetrics.Entry(date: date(year, month, day, hour: hour), type: type)
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}
