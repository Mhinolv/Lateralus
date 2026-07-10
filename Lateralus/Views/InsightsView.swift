import Charts
import SwiftData
import SwiftUI

/// Training stats: streak, volume, the week's rhythm, and per-discipline
/// balance.
struct InsightsView: View {
    @Query(sort: \Attempt.date, order: .reverse) private var attempts: [Attempt]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        statRow
                        weekChartCard
                        disciplineCard
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Insights")
        }
    }

    // MARK: - Stats

    private var statRow: some View {
        HStack(spacing: 12) {
            statTile(value: "\(streak)", label: "Day streak", symbol: "flame.fill", tint: .orange)
            statTile(value: "\(attempts.count)", label: "Ideas total", symbol: "lightbulb.fill", tint: .yellow)
            statTile(value: "\(thisWeek)", label: "This week", symbol: "calendar", tint: Theme.success)
        }
    }

    private func statTile(value: String, label: String, symbol: String, tint: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.callout)
                .foregroundStyle(tint)
            Text(value)
                .font(.system(size: 30, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(Theme.ink)
                .contentTransition(.numericText())
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .textCase(.uppercase)
                .kerning(0.8)
                .foregroundStyle(Theme.inkSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassCard(cornerRadius: 16)
    }

    // MARK: - This week

    /// Challenges solved per day over the last seven days.
    private var weekChartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("This week")
                .displayFont(20)
                .foregroundStyle(Theme.ink)
            Chart(lastWeek, id: \.day) { item in
                BarMark(
                    x: .value("Day", item.day, unit: .day),
                    y: .value("Solved", item.count)
                )
                .foregroundStyle(Theme.accentContainer)
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                        .foregroundStyle(Theme.inkTertiary)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine().foregroundStyle(Theme.cardStroke)
                    AxisValueLabel().foregroundStyle(Theme.inkTertiary)
                }
            }
            .frame(height: 150)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    // MARK: - Discipline balance

    private var disciplineCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Discipline balance")
                .displayFont(20)
                .foregroundStyle(Theme.ink)
            ForEach(ChallengeType.games) { type in
                let count = counts[type, default: 0]
                HStack(spacing: 10) {
                    Image(systemName: type.symbol)
                        .font(.caption)
                        .foregroundStyle(type.tint)
                        .frame(width: 22)
                    Text(type.title)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Theme.inkSecondary)
                        .frame(width: 110, alignment: .leading)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.07))
                            Capsule()
                                .fill(type.tint)
                                .frame(width: geo.size.width * barFraction(count))
                        }
                    }
                    .frame(height: 8)
                    Text("\(count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                        .monospacedDigit()
                        .frame(width: 32, alignment: .trailing)
                }
            }
        }
        .padding(20)
        .glassCard()
    }

    private func barFraction(_ count: Int) -> CGFloat {
        let maxCount = max(counts.values.max() ?? 1, 1)
        return CGFloat(count) / CGFloat(maxCount)
    }

    // MARK: - Derived values

    private var counts: [ChallengeType: Int] {
        Dictionary(grouping: attempts, by: \.type).mapValues(\.count)
    }

    private var streak: Int {
        let calendar = Calendar.current
        let days = Set(attempts.map { calendar.startOfDay(for: $0.date) })
        var cursor = calendar.startOfDay(for: .now)
        if !days.contains(cursor) {
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor)!
        }
        var count = 0
        while days.contains(cursor) {
            count += 1
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor)!
        }
        return count
    }

    private var thisWeek: Int {
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: .now)?.start else { return 0 }
        return attempts.filter { $0.date >= weekStart }.count
    }

    /// Attempt counts for each of the last seven days, oldest first.
    private var lastWeek: [(day: Date, count: Int)] {
        let calendar = Calendar.current
        let byDay = Dictionary(grouping: attempts) { calendar.startOfDay(for: $0.date) }
        let today = calendar.startOfDay(for: .now)
        return (0..<7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today)!
            return (day: day, count: byDay[day]?.count ?? 0)
        }
    }
}

#Preview {
    InsightsView()
        .modelContainer(for: Attempt.self, inMemory: true)
        .preferredColorScheme(.dark)
}
