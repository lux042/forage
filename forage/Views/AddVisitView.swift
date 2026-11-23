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

    @State private var isLoadingPhotos = false
    @State private var photoError: String?

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
                        Label("Add photos", systemImage: "photo.on.rectangle.angled")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    }

                    if isLoadingPhotos {
                        ProgressView("Preparing photos…")
                    }
                    if let photoError {
                        Text(photoError)
                            .font(.footnote)
                            .foregroundStyle(Color.accentOrange)
                    }
                    if !selectedPhotoDataList.isEmpty {
                        Text("\(selectedPhotoDataList.count) photo(s) ready to save")
                            .font(.caption)
                            .foregroundStyle(Color.forageHeading)
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
                    .disabled(isLoadingPhotos)
                }
            }
            .onChange(of: selectedPhotoItems) { _, _ in
                Task { await loadSelectedPhotos() }
            }
        }
    }

    @MainActor
    private func loadSelectedPhotos() async {
        isLoadingPhotos = true
        photoError = nil
        var loadedData: [Data] = []
        var failures = 0

        for item in selectedPhotoItems {
            do {
                guard let data = try await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data),
                      let jpeg = image.jpegData(compressionQuality: 0.75) else {
                    failures += 1
                    continue
                }
                loadedData.append(jpeg)
            } catch {
                failures += 1
                print("Photo import error:", error)
            }
        }

        selectedPhotoDataList = loadedData
        if failures > 0 {
            photoError = "Couldn't load \(failures) photo(s). Try another image or add photos to the simulator's Photos library."
        }
        isLoadingPhotos = false
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
