import SwiftUI
import SwiftData

@main
struct ForageApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Restaurant.self, VisitEntry.self)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .onAppear {
                    let context = ModelContext(container)
                    GeofenceManager.shared.configure(context: context)
                }
        }
    }
}
