import Foundation
import UserNotifications

final class NotificationManager {
    func requestPermission() async {
        do {
            try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Notification permission error: \(error)")
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

        UNUserNotificationCenter.current().add(request)
    }
}
