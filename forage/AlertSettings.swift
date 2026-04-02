import Foundation

enum AlertRadiusOption: Double, CaseIterable, Identifiable {
    case close = 402.336    // 0.25 mi in meters
    case standard = 804.672 // 0.5 mi in meters
    case wide = 1609.344    // 1.0 mi in meters

    var id: Double { rawValue }

    var title: String {
        switch self {
        case .close: return "Close (0.25 mi)"
        case .standard: return "Standard (0.5 mi)"
        case .wide: return "Wide (1.0 mi)"
        }
    }
}

final class AlertSettings {
    static let radiusKey = "forage_alert_radius_meters"
    static let cooldownHoursKey = "forage_alert_cooldown_hours"

    static var radiusMeters: Double {
        let saved = UserDefaults.standard.double(forKey: radiusKey)
        return saved == 0 ? AlertRadiusOption.standard.rawValue : saved
    }

    static func setRadius(_ meters: Double) {
        UserDefaults.standard.set(meters, forKey: radiusKey)
    }

    static var cooldownHours: Double {
        let saved = UserDefaults.standard.double(forKey: cooldownHoursKey)
        return saved == 0 ? 12 : saved
    }

    static func setCooldownHours(_ hours: Double) {
        UserDefaults.standard.set(hours, forKey: cooldownHoursKey)
    }
}
