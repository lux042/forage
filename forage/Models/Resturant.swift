import Foundation
import CoreLocation
import SwiftData

@Model
final class Restaurant {
    var id: UUID
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var phoneNumber: String?
    var mapPlaceID: String?

    var isSaved: Bool
    var isVisited: Bool
    var createdAt: Date
    // Optional on disk so restaurants saved before geofencing can migrate safely.
    var monitoringEnabled: Bool?

    // Existing restaurants without this field should remain eligible for alerts.
    var isMonitoringEnabled: Bool { monitoringEnabled ?? true }

    var lastAlertedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \VisitEntry.restaurant)
    var visits: [VisitEntry]

    init(
        id: UUID = UUID(),
        name: String,
        address: String,
        latitude: Double,
        longitude: Double,
        phoneNumber: String? = nil,
        mapPlaceID: String? = nil,
        isSaved: Bool = true,
        isVisited: Bool = false,
        createdAt: Date = Date(),
        monitoringEnabled: Bool = true,
        lastAlertedAt: Date? = nil,
        visits: [VisitEntry] = []
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.phoneNumber = phoneNumber
        self.mapPlaceID = mapPlaceID
        self.isSaved = isSaved
        self.isVisited = isVisited
        self.createdAt = createdAt
        self.monitoringEnabled = monitoringEnabled
        self.lastAlertedAt = lastAlertedAt
        self.visits = visits
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
