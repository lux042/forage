import SwiftUI
import SwiftData
import MapKit

struct RestaurantDetailView: View {
    @Bindable var restaurant: Restaurant
    @State private var showingAddVisit = false

    var sortedVisits: [VisitEntry] {
        restaurant.visits.sorted { $0.visitDate > $1.visitDate }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Map(position: .constant(
                    .region(
                        MKCoordinateRegion(
                            center: restaurant.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    )
                )) {
                    Marker(restaurant.name, coordinate: restaurant.coordinate)
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 8) {
                    Text(restaurant.name)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Label(restaurant.address, systemImage: "mappin.and.ellipse")
                        .foregroundStyle(.secondary)

                    if let phone = restaurant.phoneNumber, !phone.isEmpty {
                        Label(phone, systemImage: "phone")
                            .foregroundStyle(.secondary)
                    }

                    Toggle("Mark as Visited", isOn: $restaurant.isVisited)
                        .padding(.top, 6)
                }

                Button {
                    showingAddVisit = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Visit")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Visits")
                        .font(.title3)
                        .fontWeight(.semibold)

                    if sortedVisits.isEmpty {
                        Text("No visits logged yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(sortedVisits) { visit in
                            VisitCardView(visit: visit)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Restaurant")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddVisit) {
            AddVisitView(restaurant: restaurant)
        }
    }
}
