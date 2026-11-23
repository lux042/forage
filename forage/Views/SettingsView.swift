import SwiftUI
import CoreLocation

struct SettingsView: View {
    @StateObject private var geofenceManager = GeofenceManager.shared
    private let notificationManager = NotificationManager()

    @State private var selectedRadius = AlertSettings.radiusMeters
    @State private var cooldownHours = AlertSettings.cooldownHours

    var body: some View {
        NavigationStack {
            Form {
                Section("Permissions") {
                    Button("Allow Notifications") {
                        Task {
                            await notificationManager.requestPermission()
                        }
                    }

                    Button("Allow Location While Using App") {
                        geofenceManager.requestWhenInUsePermission()
                    }

                    Button("Upgrade to Always Location") {
                        geofenceManager.requestAlwaysPermission()
                    }

                    Text("Current status: \(statusText)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Nearby Alerts") {
                    Picker("Alert Radius", selection: $selectedRadius) {
                        ForEach(AlertRadiusOption.allCases) { option in
                            Text(option.title).tag(option.rawValue)
                        }
                    }
                    .onChange(of: selectedRadius) { _, newValue in
                        AlertSettings.setRadius(newValue)
                    }

                    Picker("Cooldown", selection: $cooldownHours) {
                        Text("6 hours").tag(6.0)
                        Text("12 hours").tag(12.0)
                        Text("24 hours").tag(24.0)
                    }
                    .onChange(of: cooldownHours) { _, newValue in
                        AlertSettings.setCooldownHours(newValue)
                    }
                }
            }
            .navigationTitle("Settings")
            .scrollContentBackground(.hidden)
            .background(Color.backgroundSoft.ignoresSafeArea())
            .tint(Color.forageAction)
        }
    }

    private var statusText: String {
        switch geofenceManager.authorizationStatus {
        case .notDetermined: return "Not determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedWhenInUse: return "When In Use"
        case .authorizedAlways: return "Always"
        @unknown default: return "Unknown"
        }
    }
}
