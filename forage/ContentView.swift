import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }

            SavedView()
                .tabItem {
                    Label("Saved", systemImage: "star.fill")
                }

            JournalView()
                .tabItem {
                    Label("Foraged", systemImage: "book.pages")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}
