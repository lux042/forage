import Foundation
import CoreLocation
import SwiftData

@MainActor
final class NearbyAlertService {
    static let shared = NearbyAlertService()

    private init() {}

    func checkNearbySavedRestaurants(
        userLocation: CLLocation,
        savedRestaurants: [Restaurant],
        notify: (Restaurant) -> Void
    ) {
        let radiusMeters = AlertSettings.radiusMeters
        let cooldownHours = AlertSettings.cooldownHours
        let now = Date()

        for restaurant in savedRestaurants {
            let restaurantLocation = CLLocation(
                latitude: restaurant.latitude,
                longitude: restaurant.longitude
            )

            let distance = userLocation.distance(from: restaurantLocation)

            guard distance <= radiusMeters else { continue }

            if let lastAlertedAt = restaurant.lastAlertedAt {
                let hoursSinceLastAlert = now.timeIntervalSince(lastAlertedAt) / 3600
                guard hoursSinceLastAlert >= cooldownHours else { continue }
            }

            restaurant.lastAlertedAt = now
            notify(restaurant)
        }
    }
}
