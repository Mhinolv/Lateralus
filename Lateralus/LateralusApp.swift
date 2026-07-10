import SwiftData
import SwiftUI

@main
struct LateralusApp: App {
    let container: ModelContainer = {
        do {
            return try ModelContainer(for: Attempt.self)
        } catch {
            fatalError("Could not create local store: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(container)
    }
}
