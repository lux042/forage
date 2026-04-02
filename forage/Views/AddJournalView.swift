import SwiftUI
import SwiftData

struct JournalView: View {
    @Query(sort: \VisitEntry.visitDate, order: .reverse) private var visits: [VisitEntry]

    var body: some View {
        NavigationStack {
            Group {
                if visits.isEmpty {
                    ContentUnavailableView(
                        "No Journal Entries",
                        systemImage: "book.pages",
                        description: Text("Add a visit from one of your saved restaurants.")
                    )
                } else {
                    List {
                        ForEach(visits) { visit in
                            VStack(alignment: .leading, spacing: 10) {
                                if let restaurantName = visit.restaurant?.name {
                                    Text(restaurantName)
                                        .font(.headline)
                                }

                                Text(visit.title.isEmpty ? "Visit" : visit.title)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Text(visit.visitDate, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                if let firstPhoto = visit.photoDataList.first,
                                   let uiImage = UIImage(data: firstPhoto) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 160)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }

                                if visit.rating > 0 {
                                    HStack(spacing: 2) {
                                        ForEach(1...5, id: \.self) { star in
                                            Image(systemName: star <= visit.rating ? "star.fill" : "star")
                                        }
                                    }
                                    .foregroundStyle(.yellow)
                                }

                                if !visit.notes.isEmpty {
                                    Text(visit.notes)
                                        .font(.subheadline)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Journal")
        }
    }
}
