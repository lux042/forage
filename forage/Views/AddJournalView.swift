import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VisitEntry.visitDate, order: .reverse) private var visits: [VisitEntry]
    @State private var editingVisit: VisitEntry?
    @State private var deletingVisit: VisitEntry?
    @State private var saveError: String?

    var body: some View {
        NavigationStack {
            Group {
                if visits.isEmpty {
                    ContentUnavailableView(
                        "Your field notes start here",
                        systemImage: "book.closed",
                        description: Text("Log a visit from a saved restaurant to remember what you loved.")
                    )
                } else {
                    List {
                        Section {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Your food journal")
                                    .font(.title2.bold())
                                    .foregroundStyle(Color.primaryBlue)
                                Text("\(visits.count) \(visits.count == 1 ? "memory" : "memories") collected")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 8)
                            .listRowBackground(Color.clear)
                        }

                        ForEach(visits) { visit in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Label(visit.restaurant?.name ?? "Restaurant", systemImage: "leaf")
                                        .font(.headline)
                                        .foregroundStyle(Color.primaryBlue)
                                    Spacer()
                                    Menu {
                                        Button("Edit entry", systemImage: "pencil") {
                                            editingVisit = visit
                                        }
                                        Button("Delete entry", systemImage: "trash", role: .destructive) {
                                            deletingVisit = visit
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis.circle")
                                            .font(.title3)
                                            .foregroundStyle(Color.primaryBlue)
                                            .frame(width: 44, height: 44)
                                            .contentShape(Rectangle())
                                    }
                                    .accessibilityLabel("Options for \(visit.title.isEmpty ? "visit" : visit.title)")
                                }

                                VisitCardView(visit: visit)
                            }
                            .padding(.vertical, 6)
                            .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Edit", systemImage: "pencil") {
                                    editingVisit = visit
                                }
                                .tint(.primaryBlue)

                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    deletingVisit = visit
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color.backgroundSoft.ignoresSafeArea())
            .navigationTitle("Foraged")
            .tint(.primaryBlue)
            .sheet(item: $editingVisit) { visit in
                EditVisitView(visit: visit)
            }
            .confirmationDialog(
                "Delete this journal entry?",
                isPresented: Binding(
                    get: { deletingVisit != nil },
                    set: { if !$0 { deletingVisit = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete Entry", role: .destructive) {
                    if let visit = deletingVisit { delete(visit) }
                    deletingVisit = nil
                }
                Button("Cancel", role: .cancel) { deletingVisit = nil }
            } message: {
                Text("This removes the review and its photos. It cannot be undone.")
            }
            .alert("Could not delete entry", isPresented: Binding(
                get: { saveError != nil },
                set: { if !$0 { saveError = nil } }
            )) {
                Button("OK", role: .cancel) { saveError = nil }
            } message: {
                Text(saveError ?? "")
            }
        }
    }

    private func delete(_ visit: VisitEntry) {
        // Save the relationship before deletion so a failed save can be rolled back.
        modelContext.delete(visit)
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            saveError = error.localizedDescription
        }
    }
}

private struct EditVisitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let visit: VisitEntry
    @State private var visitDate: Date
    @State private var title: String
    @State private var notes: String
    @State private var rating: Int
    @State private var wouldReturn: Bool
    @State private var orderDetails: String
    @State private var errorMessage: String?

    init(visit: VisitEntry) {
        self.visit = visit
        _visitDate = State(initialValue: visit.visitDate)
        _title = State(initialValue: visit.title)
        _notes = State(initialValue: visit.notes)
        _rating = State(initialValue: visit.rating)
        _wouldReturn = State(initialValue: visit.wouldReturn)
        _orderDetails = State(initialValue: visit.orderDetails)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("The visit") {
                    DatePicker("Date", selection: $visitDate, displayedComponents: .date)
                    TextField("Title", text: $title)
                    TextField("What did you order?", text: $orderDetails)
                }

                Section("Rating") {
                    HStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                rating = star
                            } label: {
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundStyle(Color.accentGold)
                                    .frame(minWidth: 36, minHeight: 44)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("\(star) stars")
                        }
                    }
                }

                Section("Field notes") {
                    TextField("Your notes", text: $notes, axis: .vertical)
                        .lineLimit(4...8)
                    Toggle("Would return", isOn: $wouldReturn)
                }

                if !visit.photoDataList.isEmpty {
                    Section("Photos") {
                        Text("Existing photos are preserved when you edit this entry.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Visit")
            .navigationBarTitleDisplayMode(.inline)
            .tint(.primaryBlue)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                }
            }
            .alert("Could not save changes", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func save() {
        visit.visitDate = visitDate
        visit.title = title
        visit.notes = notes
        visit.rating = rating
        visit.wouldReturn = wouldReturn
        visit.orderDetails = orderDetails

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            errorMessage = error.localizedDescription
        }
    }
}
