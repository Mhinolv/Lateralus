import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var appNow = Date.now

    var body: some View {
        TabView {
            Tab("Today", systemImage: "sun.max.fill") {
                TodayView()
            }
            Tab("Journal", systemImage: "book.closed.fill") {
                JournalView()
            }
            Tab("Insights", systemImage: "chart.line.uptrend.xyaxis") {
                InsightsView()
            }
        }
        .tint(Theme.accent)
        .environment(\.appNow, appNow)
        .task {
            try? AttemptRepository(context: modelContext).reconcileAttachments()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { refreshClock() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            refreshClock()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)) { _ in
            refreshClock()
        }
    }

    private func refreshClock() {
        appNow = .now
    }
}

private struct AppNowKey: EnvironmentKey {
    static let defaultValue = Date.now
}

extension EnvironmentValues {
    var appNow: Date {
        get { self[AppNowKey.self] }
        set { self[AppNowKey.self] = newValue }
    }
}

#Preview {
    RootView()
        .modelContainer(for: Attempt.self, inMemory: true)
        .preferredColorScheme(.dark)
}
