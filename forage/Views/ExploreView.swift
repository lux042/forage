import SwiftUI
import MapKit
import SwiftData

struct ExploreView: View {
    @StateObject private var searchService = RestaurantSearchService()
    @StateObject private var locationManager = LocationManager()

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Restaurant.createdAt, order: .reverse) private var savedRestaurants: [Restaurant]

    @State private var query = ""
    @State private var showMap = true
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var animatingKeys: Set<String> = []

    var currentRegion: MKCoordinateRegion? {
        guard let location = locationManager.lastLocation else { return nil }
        return MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Find your next favorite")
                            .font(.system(.title2, design: .serif, weight: .bold))
                            .foregroundStyle(Color.forageHeading)
                        Text("A little exploring goes a long way.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        withAnimation { showMap.toggle() }
                    } label: {
                        Label(showMap ? "List" : "Map", systemImage: showMap ? "list.bullet" : "map")
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                if showMap { mapSection }

                Group {
                    if searchService.isLoading {
                        VStack {
                            Spacer()
                            ProgressView("Searching...")
                                .tint(Color.forageAction)
                            Spacer()
                        }
                    } else if searchService.results.isEmpty {
                        ContentUnavailableView(
                            "The search starts here",
                            systemImage: "leaf",
                            description: Text("Search for a restaurant or tap Near Me to explore.")
                        )
                    } else {
                        resultsList
                    }
                }
            }
            .background(Color.backgroundSoft.ignoresSafeArea())
            .navigationTitle("Explore")
            .tint(Color.forageAction)
            .searchable(text: $query, prompt: "Name, cuisine, or neighborhood")
            .onSubmit(of: .search) {
                Task {
                    await searchService.search(query: query, near: currentRegion)
                    updateCameraToResults()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Near Me") {
                        locationManager.requestWhenInUsePermission()
                        locationManager.startUpdating()

                        Task {
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                            await searchService.search(query: "restaurants", near: currentRegion)
                            updateCameraToUserOrResults()
                        }
                    }
                }
            }
            .onChange(of: locationManager.lastLocation) { _, _ in
                updateCameraToUserOrResults()
            }
        }
    }

    private var mapSection: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()

            ForEach(searchService.results) { result in
                let coordinate = CLLocationCoordinate2D(
                    latitude: result.latitude,
                    longitude: result.longitude
                )

                Marker(result.name, coordinate: coordinate)
                    .tint(Color.forageAction)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .frame(height: 240)
        .clipShape(
            RoundedRectangle(cornerRadius: 24)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.forageSage.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private var resultsList: some View {
        List {
            Section {
                ForEach(searchService.results) { result in
                    HStack(alignment: .center, spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.forageSage.opacity(0.18))
                            Image(systemName: "fork.knife")
                                .font(.title2)
                                .foregroundStyle(Color.forageHeading)
                        }
                        .frame(width: 58, height: 62)

                        VStack(alignment: .leading, spacing: 7) {
                            Text(result.name)
                                .font(.system(.headline, design: .serif))
                                .foregroundStyle(Color.forageHeading)
                                .fixedSize(horizontal: false, vertical: true)

                            Label(result.address, systemImage: "mappin")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)

                            if let phone = result.phoneNumber, !phone.isEmpty {
                                Label(phone, systemImage: "phone")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer(minLength: 0)

                        Button {
                            toggleSaved(result)
                        } label: {
                            let key = resultKey(for: result)
                            Image(systemName: isSaved(result) ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 19, weight: .semibold))
                                .foregroundStyle(isSaved(result) ? Color.accentOrange : Color.forageHeading)
                                .frame(width: 44, height: 44)
                                .background(Color.forageSage.opacity(0.13), in: Circle())
                                .scaleEffect(animatingKeys.contains(key) ? 1.15 : 1)
                                .animation(.spring(response: 0.28, dampingFraction: 0.5), value: animatingKeys.contains(key))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(isSaved(result) ? "Remove \(result.name) from saved" : "Save \(result.name)")
                    }
                    .padding(.vertical, 12)
                    .listRowBackground(Color.forageCard)
                    .listRowSeparatorTint(Color.forageSage.opacity(0.2))
                }
            } header: {
                HStack {
                    Text("Places to discover")
                        .font(.system(.headline, design: .serif))
                    Spacer()
                    Text("\(searchService.results.count) found")
                        .font(.caption)
                }
                .textCase(nil)
                .foregroundStyle(Color.forageHeading)
            }
        }
        .listStyle(.insetGrouped)
        .environment(\.defaultMinListRowHeight, 86)
        .scrollContentBackground(.hidden)
        .background(Color.backgroundSoft)
    }

    private func resultKey(for result: RestaurantSearchResult) -> String {
        if let id = result.mapPlaceID, !id.isEmpty {
            return "place:\(id)"
        }

        return "coord:\(result.name)|\(result.address)|\(result.latitude)|\(result.longitude)"
    }

    private func restaurantKey(for restaurant: Restaurant) -> String {
        if let id = restaurant.mapPlaceID, !id.isEmpty {
            return "place:\(id)"
        }

        return "coord:\(restaurant.name)|\(restaurant.address)|\(restaurant.latitude)|\(restaurant.longitude)"
    }

    private func matchingSavedRestaurant(for result: RestaurantSearchResult) -> Restaurant? {
        let key = resultKey(for: result)

        return savedRestaurants.first { restaurant in
            restaurantKey(for: restaurant) == key
        }
    }

    private func isSaved(_ result: RestaurantSearchResult) -> Bool {
        matchingSavedRestaurant(for: result) != nil
    }

    private func triggerStarAnimation(for key: String) {
        animatingKeys.insert(key)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            animatingKeys.remove(key)
        }
    }

    private func toggleSaved(_ result: RestaurantSearchResult) {
        let key = resultKey(for: result)
        triggerStarAnimation(for: key)

        do {
            if let existing = matchingSavedRestaurant(for: result) {
                modelContext.delete(existing)
                GeofenceManager.shared.stopMonitoring(restaurant: existing)
                print("Removed:", result.name)
            } else {
                let restaurant = Restaurant(
                    name: result.name,
                    address: result.address,
                    latitude: result.latitude,
                    longitude: result.longitude,
                    phoneNumber: result.phoneNumber,
                    mapPlaceID: result.mapPlaceID,
                    monitoringEnabled: true
                )

                modelContext.insert(restaurant)
                GeofenceManager.shared.startMonitoring(restaurant: restaurant)
                print("Saved:", result.name)
            }

            try modelContext.save()
            GeofenceManager.shared.refreshGeofences(userLocation: locationManager.lastLocation)
            
        
            
        } catch {
            print("Save error:", error)
        }
    }

    private func updateCameraToUserOrResults() {
        if let region = currentRegion {
            cameraPosition = .region(region)
        } else {
            updateCameraToResults()
        }
    }

    private func updateCameraToResults() {
        guard let first = searchService.results.first else { return }

        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: first.latitude,
                longitude: first.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )

        cameraPosition = .region(region)
    }
}
