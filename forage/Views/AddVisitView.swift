import SwiftUI
import SwiftData
import PhotosUI

struct AddVisitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let restaurant: Restaurant

    @State private var visitDate = Date()
    @State private var title = ""
    @State private var notes = ""
    @State private var rating = 0
    @State private var wouldReturn = true
    @State private var orderDetails = ""

    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var selectedPhotoDataList: [Data] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Visit Details") {
                    DatePicker("Date", selection: $visitDate, displayedComponents: .date)
                    TextField("Title (optional)", text: $title)
                    TextField("What did you order?", text: $orderDetails)
                }

                Section("Rating") {
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                rating = star
                            } label: {
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .foregroundStyle(Color.accentGold)
                }

                Section("Review") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(4...8)

                    Toggle("Would return", isOn: $wouldReturn)
                }

                Section("Photos") {
                    PhotosPicker(
                        selection: $selectedPhotoItems,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        Label("Choose Photos", systemImage: "photo.on.rectangle")
                    }

                    if !selectedPhotoDataList.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(selectedPhotoDataList.enumerated()), id: \.offset) { _, data in
                                    if let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 140, height: 140)
                                            .clipped()
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Add Visit")
            .scrollContentBackground(.hidden)
            .background(Color.backgroundSoft.ignoresSafeArea())
            .tint(Color.forageAction)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveVisit()
                    }
                }
            }
            .task(id: selectedPhotoItems) {
                await loadSelectedPhotos()
            }
        }
    }

    private func loadSelectedPhotos() async {
        var loadedData: [Data] = []

        for item in selectedPhotoItems {
            if let data = try? await item.loadTransferable(type: Data.self) {
                loadedData.append(data)
            }
        }

        selectedPhotoDataList = loadedData
    }

    private func saveVisit() {
        let visit = VisitEntry(
            visitDate: visitDate,
            title: title,
            notes: notes,
            rating: rating,
            wouldReturn: wouldReturn,
            orderDetails: orderDetails,
            photoDataList: selectedPhotoDataList,
            restaurant: restaurant
        )

        restaurant.visits.append(visit)

        if !restaurant.isVisited {
            restaurant.isVisited = true
        }

        modelContext.insert(visit)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save visit: \(error)")
        }
    }
}
