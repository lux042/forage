import SwiftUI

struct VisitCardView: View {
    let visit: VisitEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !visit.photoDataList.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(visit.photoDataList.enumerated()), id: \.offset) { _, data in
                            if let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 180, height: 180)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
            }

            HStack {
                Text(visit.title.isEmpty ? "Visit" : visit.title)
                    .font(.headline)

                Spacer()

                Text(visit.visitDate, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if visit.rating > 0 {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= visit.rating ? "star.fill" : "star")
                    }
                }
                .foregroundStyle(Color.accentGold)
            }

            if !visit.orderDetails.isEmpty {
                Text("Ordered: \(visit.orderDetails)")
                    .font(.subheadline)
            }

            if !visit.notes.isEmpty {
                Text(visit.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Label(
                visit.wouldReturn ? "Would return" : "Would not return",
                systemImage: visit.wouldReturn ? "arrow.clockwise.circle.fill" : "xmark.circle"
            )
            .font(.caption)
            .foregroundStyle(visit.wouldReturn ? .green : .red)
        }
        .padding()
        .background(Color.forageCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
