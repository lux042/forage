import Foundation
import UserNotifications

final class NotificationManager {
    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            print("🔔 Notification permission granted: \(granted)")
        } catch {
            print("🔔 Notification permission error: \(error)")
        }
    }

    func sendNearbyNotification(for restaurant: Restaurant) {
        let content = UNMutableNotificationContent()
        content.title = "Near saved spot"
        content.body = "You're near \(restaurant.name) — \(restaurant.address)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "nearby-\(restaurant.id.uuidString)",
            content: content,
            trigger: trigger
        )

        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            print("🔔 Authorization status: \(settings.authorizationStatus.rawValue)")
            center.add(request) { error in
                if let error {
                    print("🔔 Failed to schedule nearby notification for \(restaurant.name): \(error)")
                } else {
                    print("🔔 Scheduled nearby notification for \(restaurant.name)")
                }
            }
        }
    }
}
