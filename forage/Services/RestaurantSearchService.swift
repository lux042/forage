import Foundation
import MapKit
import Combine

struct RestaurantSearchResult: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let phoneNumber: String?
    let mapPlaceID: String?
}

@MainActor
final class RestaurantSearchService: ObservableObject {
    @Published var results: [RestaurantSearchResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func search(query: String, near region: MKCoordinateRegion?) async {
        let cleanedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedQuery.isEmpty else {
            results = []
            errorMessage = nil
            return
        }

        isLoading = true
        errorMessage = nil

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = cleanedQuery
        request.resultTypes = .pointOfInterest

        if let region {
            request.region = region
        }

        do {
            let response = try await MKLocalSearch(request: request).start()

            let mappedResults = response.mapItems.map { item in
                let coordinate = item.location.coordinate

                let cleanedName = {
                    let raw = item.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    return raw.isEmpty ? "Unknown Place" : raw
                }()

                let addressText =
                    item.address?.shortAddress
                    ?? item.address?.fullAddress
                    ?? "Address unavailable"

                return RestaurantSearchResult(
                    name: cleanedName,
                    address: addressText,
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    phoneNumber: item.phoneNumber,
                    mapPlaceID: item.identifier?.description
                )
            }

            results = mappedResults

            if mappedResults.isEmpty {
                errorMessage = "No restaurants found."
            }
        } catch {
            results = []
            errorMessage = "Search failed. Please try again."
            print("Search failed: \(error)")
        }

        isLoading = false
    }
}
