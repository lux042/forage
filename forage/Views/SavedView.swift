import SwiftUI
import SwiftData

struct SavedView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Restaurant.createdAt, order: .reverse) private var restaurants: [Restaurant]

    @StateObject private var geofenceManager = GeofenceManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundSoft
                    .ignoresSafeArea()

                if restaurants.isEmpty {
                    ContentUnavailableView(
                        "Your next discovery awaits",
                        systemImage: "leaf",
                        description: Text("Save restaurants from Explore to grow your wish list.")
                    )
                } else {
                    List {
                        ForEach(restaurants) { restaurant in
                            HStack(alignment: .top, spacing: 12) {
                                NavigationLink {
                                    RestaurantDetailView(restaurant: restaurant)
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(restaurant.name)
                                            .font(.headline)
                                            .foregroundStyle(Color.forestGreen)

                                        Text(restaurant.address)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)

                                        HStack(spacing: 8) {
                                            Label("\(restaurant.visits.count)", systemImage: "book.pages")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)

                                            if restaurant.isVisited {
                                                Label("Visited", systemImage: "checkmark.circle.fill")
                                                    .font(.caption)
                                                    .foregroundStyle(.green)
                                            }

                                            monitoringRow(for: restaurant)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 6)
                                }
                                .buttonStyle(.plain)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    removeRestaurant(restaurant)
                                } label: {
                                    Label("Unsave", systemImage: "star.slash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.backgroundSoft)
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Saved Spots")
            .tint(.forestGreen)
        }
    }

    private func monitoringRow(for restaurant: Restaurant) -> some View {
        let isActive = geofenceManager.isMonitoring(restaurant)
        let isEnabled = restaurant.isMonitoringEnabled

        return Button {
            toggleMonitoring(restaurant)
        } label: {
            Text(statusText(isActive: isActive, isEnabled: isEnabled))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(statusColor(isActive: isActive, isEnabled: isEnabled))
                .scaleEffect(restaurant.isMonitoringEnabled ? 1.0 : 0.96)
                .animation(.easeInOut(duration: 0.15), value: restaurant.monitoringEnabled)
        }
        .buttonStyle(.plain)
    }

    private func toggleMonitoring(_ restaurant: Restaurant) {
        do {
            restaurant.monitoringEnabled = !restaurant.isMonitoringEnabled
            try modelContext.save()

            GeofenceManager.shared.refreshGeofences(userLocation: nil)
            print("Toggled monitoring:", restaurant.name, restaurant.isMonitoringEnabled)
        } catch {
            print("Failed to toggle monitoring:", error)
        }
    }

    private func statusText(isActive: Bool, isEnabled: Bool) -> String {
        if isActive {
            return "Monitoring"
        } else if isEnabled {
            return "Queued"
        } else {
            return "Off"
        }
    }

    private func statusColor(isActive: Bool, isEnabled: Bool) -> Color {
        if isActive {
            return .green
        } else if isEnabled {
            return .orange
        } else {
            return .secondary
        }
    }

    private func removeRestaurant(_ restaurant: Restaurant) {
        do {
            GeofenceManager.shared.stopMonitoring(restaurant: restaurant)
            modelContext.delete(restaurant)
            try modelContext.save()
            GeofenceManager.shared.refreshGeofences(userLocation: nil)
            print("Removed from Saved:", restaurant.name)
        } catch {
            print("Failed to remove restaurant:", error)
        }
    }
}
