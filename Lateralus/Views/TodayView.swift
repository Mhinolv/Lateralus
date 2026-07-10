import SwiftData
import SwiftUI

struct TodayView: View {
    @Query(sort: \Attempt.date, order: .reverse) private var attempts: [Attempt]
    @State private var activeChallenge: ChallengeSelection?

    private var daily: Challenge { ChallengeEngine.daily() }

    private var dailyDone: Bool {
        attempts.contains { $0.isDaily && Calendar.current.isDateInToday($0.date) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(accent: daily.type.tint)
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header
                        dailyCard
                        practiceSection
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
            .toolbarVisibility(.hidden, for: .navigationBar)
        }
        .sheet(item: $activeChallenge) { selection in
            ChallengeView(challenge: selection.challenge, isDaily: selection.isDaily)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(Date.now, format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(.footnote.weight(.semibold))
                    .textCase(.uppercase)
                    .kerning(1.4)
                    .foregroundStyle(Theme.inkTertiary)
                Spacer()
                StreakPill(days: streak)
            }
            Text("Think sideways.")
                .displayFont(22)
                .foregroundStyle(Theme.ink)
        }
    }

    private var dailyCard: some View {
        Button {
            activeChallenge = ChallengeSelection(challenge: daily, isDaily: true)
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Today · \(daily.type.title)")
                        .font(.caption.weight(.bold))
                        .textCase(.uppercase)
                        .kerning(1.1)
                        .foregroundStyle(daily.type.onTint)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(daily.type.onTint.opacity(0.14), in: .capsule)
                    Spacer()
                    if dailyDone {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(daily.type.onTint)
                            .font(.title3)
                    }
                }
                Image(systemName: daily.type.symbol)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(daily.type.onTint)
                Text(daily.primary)
                    .displayFont(28)
                    .foregroundStyle(daily.type.onTint)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                if let secondary = daily.secondary, let label = daily.secondaryLabel {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(label)
                            .font(.caption.weight(.bold))
                            .textCase(.uppercase)
                            .kerning(1.2)
                            .foregroundStyle(daily.type.onTint.opacity(0.75))
                        Text(secondary)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(daily.type.onTint)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(daily.type.onTint.opacity(0.12), in: .rect(cornerRadius: 16))
                }
                Label(dailyDone ? "Answer again" : "Begin", systemImage: "arrow.right")
                    .font(.headline)
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(daily.type.tint)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(daily.type.onTint, in: .capsule)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(daily.type.tint, in: .rect(cornerRadius: 24))
        }
        .buttonStyle(.plain)
    }

    private var practiceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Practice")
                .displayFont(24)
                .foregroundStyle(Theme.ink)
            Text("Any discipline, any time. Fresh prompts every round.")
                .font(.subheadline)
                .foregroundStyle(Theme.inkSecondary)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(ChallengeType.games) { type in
                    Button {
                        activeChallenge = ChallengeSelection(
                            challenge: ChallengeEngine.practice(type: type),
                            isDaily: false
                        )
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Image(systemName: type.symbol)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(type.onTint)
                            Text(type.title)
                                .font(.headline)
                                .foregroundStyle(type.onTint)
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Text(type.blurb)
                                .font(.caption)
                                .foregroundStyle(type.onTint.opacity(0.8))
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .frame(height: 140)
                        .background(type.tint, in: .rect(cornerRadius: 20))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    /// Consecutive days with at least one attempt, counting back from today
    /// (yesterday keeps the streak alive if today is still empty).
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
}

/// Identifiable wrapper so a challenge can drive a sheet.
struct ChallengeSelection: Identifiable {
    let challenge: Challenge
    let isDaily: Bool
    var id: String { challenge.id }
}

#Preview {
    TodayView()
        .modelContainer(for: Attempt.self, inMemory: true)
        .preferredColorScheme(.dark)
}
