import SwiftData
import SwiftUI

struct RootView: View {
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
    }
}

#Preview {
    RootView()
        .modelContainer(for: Attempt.self, inMemory: true)
        .preferredColorScheme(.dark)
}
