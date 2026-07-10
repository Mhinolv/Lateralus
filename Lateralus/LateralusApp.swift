import SwiftData
import SwiftUI

@main
struct LateralusApp: App {
    @State private var persistence = PersistenceController()

    var body: some Scene {
        WindowGroup {
            Group {
                if let container = persistence.container {
                    RootView()
                        .modelContainer(container)
                } else {
                    PersistenceRecoveryView(
                        details: persistence.errorMessage,
                        retry: persistence.load
                    )
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

private struct PersistenceRecoveryView: View {
    let details: String?
    let retry: () -> Void

    var body: some View {
        ZStack {
            AppBackground()
            ContentUnavailableView {
                Label("Journal unavailable", systemImage: "externaldrive.badge.exclamationmark")
            } description: {
                Text("Lateralus couldn't open your journal. Your existing entries have not been deleted.")
            } actions: {
                Button("Try Again", action: retry)
                    .buttonStyle(.borderedProminent)
                if let details, !details.isEmpty {
                    Text(details)
                        .font(.caption)
                        .foregroundStyle(Theme.inkTertiary)
                        .textSelection(.enabled)
                }
            }
        }
    }
}
