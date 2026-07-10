import Charts
import SwiftData
import SwiftUI

/// Training stats: streak, volume, the week's rhythm, and per-discipline
/// balance.
struct InsightsView: View {
    @Environment(\.appNow) private var appNow
    @Query(sort: \Attempt.date, order: .reverse) private var attempts: [Attempt]

    private var metrics: ActivityMetrics { ActivityMetrics(attempts: attempts, now: appNow) }

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
            statTile(value: "\(metrics.streak)", label: "Day streak", symbol: "flame.fill", tint: .orange)
            statTile(value: "\(metrics.total)", label: "Entries total", symbol: "lightbulb.fill", tint: .yellow)
            statTile(value: "\(metrics.thisWeek)", label: "This week", symbol: "calendar", tint: Theme.success)
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

    // MARK: - Last seven days

    /// Journal entries per day over the last seven days.
    private var weekChartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Last 7 days")
                .displayFont(20)
                .foregroundStyle(Theme.ink)
            Chart(metrics.lastSevenDays, id: \.day) { item in
                BarMark(
                    x: .value("Day", item.day, unit: .day),
                    y: .value("Entries", item.count)
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
                let count = metrics.disciplineCounts[type, default: 0]
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
        let maxCount = max(metrics.disciplineCounts.values.max() ?? 1, 1)
        return CGFloat(count) / CGFloat(maxCount)
    }

}

#Preview {
    InsightsView()
        .modelContainer(for: Attempt.self, inMemory: true)
        .preferredColorScheme(.dark)
}
