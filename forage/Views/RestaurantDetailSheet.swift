import SwiftUI
import SwiftData
import MapKit

struct RestaurantDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var restaurant: Restaurant
    @State private var showingAddVisit = false

    private var sortedVisits: [VisitEntry] {
        restaurant.visits.sorted { $0.visitDate > $1.visitDate }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "leaf.fill")
                            .foregroundStyle(Color.forageSage)
                        Text("YOUR FIELD GUIDE")
                            .font(.caption.weight(.bold))
                            .tracking(2)
                            .foregroundStyle(Color.forageSage)
                    }

                    Text(restaurant.name)
                        .font(.system(.largeTitle, design: .serif, weight: .bold))
                        .foregroundStyle(Color.forestGreen)
                        .fixedSize(horizontal: false, vertical: true)

                    Label(restaurant.address, systemImage: "mappin.circle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        Label(restaurant.isVisited ? "Visited" : "Want to visit",
                              systemImage: restaurant.isVisited ? "checkmark.circle.fill" : "bookmark")
                        Label("\(sortedVisits.count) \(sortedVisits.count == 1 ? "entry" : "entries")",
                              systemImage: "book.closed")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.forestGreen)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Map(position: .constant(
                    .region(
                        MKCoordinateRegion(
                            center: restaurant.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    )
                )) {
                    Marker(restaurant.name, coordinate: restaurant.coordinate)
                        .tint(Color.forestGreen)
                }
                .frame(height: 210)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.forestGreen.opacity(0.12), lineWidth: 1)
                }
                .accessibilityLabel("Map showing \(restaurant.name)")

                VStack(alignment: .leading, spacing: 14) {
                    if let phone = restaurant.phoneNumber, !phone.isEmpty {
                        Label(phone, systemImage: "phone")
                            .font(.subheadline)
                            .textSelection(.enabled)
                    }

                    Toggle("Mark as visited", isOn: $restaurant.isVisited)
                        .tint(Color.forestGreen)
                        .onChange(of: restaurant.isVisited) { _, _ in
                            do { try modelContext.save() }
                            catch { print("Failed to update visited status:", error) }
                        }
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))

                Button {
                    showingAddVisit = true
                } label: {
                    Label("Add a field note", systemImage: "square.and.pencil")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.forestGreen)
                .controlSize(.large)

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Field notes")
                            .font(.system(.title2, design: .serif, weight: .bold))
                            .foregroundStyle(Color.forestGreen)
                        Spacer()
                        Text("\(sortedVisits.count)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    if sortedVisits.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: "book.closed")
                                .font(.title2)
                                .foregroundStyle(Color.forageSage)
                            Text("No memories collected yet")
                                .font(.headline)
                            Text("After you visit, add a note about what made this spot special.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    } else {
                        ForEach(sortedVisits) { visit in
                            VisitCardView(visit: visit)
                        }
                    }
                }
            }
            .padding(18)
        }
        .background(Color.backgroundSoft.ignoresSafeArea())
        .navigationTitle("Field Guide")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color.forestGreen)
        .sheet(isPresented: $showingAddVisit) {
            AddVisitView(restaurant: restaurant)
        }
    }
}
