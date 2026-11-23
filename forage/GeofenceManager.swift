import Foundation
import CoreLocation
import SwiftData
import Combine

@MainActor
final class GeofenceManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = GeofenceManager()

    private let manager = CLLocationManager()
    private let notificationManager = NotificationManager()

    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var monitoredRestaurantIDs: Set<String> = []

    private var modelContext: ModelContext?

    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        syncMonitoredIDs()
    }

    func configure(context: ModelContext) {
        self.modelContext = context
        syncMonitoredIDs()
    }

    func requestWhenInUsePermission() {
        manager.requestWhenInUseAuthorization()
    }

    func requestAlwaysPermission() {
        manager.requestAlwaysAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        syncMonitoredIDs()
    }

    func refreshGeofences(userLocation: CLLocation?) {
        guard let modelContext else { return }

        do {
            let allRestaurants = try modelContext.fetch(FetchDescriptor<Restaurant>())
            let restaurants = allRestaurants.filter { $0.isMonitoringEnabled }

            for region in manager.monitoredRegions {
                manager.stopMonitoring(for: region)
            }

            let sorted = restaurants.sorted {
                guard let userLocation else { return true }

                let d1 = CLLocation(latitude: $0.latitude, longitude: $0.longitude)
                    .distance(from: userLocation)

                let d2 = CLLocation(latitude: $1.latitude, longitude: $1.longitude)
                    .distance(from: userLocation)

                return d1 < d2
            }

            let limited = sorted.prefix(20)

            for restaurant in limited {
                startMonitoring(restaurant: restaurant)
            }

            syncMonitoredIDs()
            print("🔄 Monitoring \(limited.count) geofences")
        } catch {
            print("Geofence refresh error:", error)
        }
    }

    func startMonitoring(restaurant: Restaurant) {
        guard restaurant.isMonitoringEnabled else { return }

        let center = CLLocationCoordinate2D(
            latitude: restaurant.latitude,
            longitude: restaurant.longitude
        )

        let region = CLCircularRegion(
            center: center,
            radius: max(AlertSettings.radiusMeters, 200),
            identifier: restaurant.id.uuidString
        )

        region.notifyOnEntry = true
        region.notifyOnExit = false

        manager.startMonitoring(for: region)
        syncMonitoredIDs()
    }

    func stopMonitoring(restaurant: Restaurant) {
        for region in manager.monitoredRegions {
            if region.identifier == restaurant.id.uuidString {
                manager.stopMonitoring(for: region)
            }
        }
        syncMonitoredIDs()
    }

    func isMonitoring(_ restaurant: Restaurant) -> Bool {
        monitoredRestaurantIDs.contains(restaurant.id.uuidString)
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("🔥 ENTERED REGION:", region.identifier)

        guard let modelContext else { return }

        do {
            let restaurants = try modelContext.fetch(FetchDescriptor<Restaurant>())

            if let match = restaurants.first(where: {
                $0.id.uuidString == region.identifier
            }) {
                notificationManager.sendNearbyNotification(for: match)
            }
        } catch {
            print("Geofence lookup error:", error)
        }
    }

    private func syncMonitoredIDs() {
        monitoredRestaurantIDs = Set(manager.monitoredRegions.map(\.identifier))
    }
}
