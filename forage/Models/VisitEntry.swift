import Foundation
import SwiftData

@Model
final class VisitEntry {
    var id: UUID
    var visitDate: Date
    var title: String
    var notes: String
    var rating: Int
    var wouldReturn: Bool
    var orderDetails: String
    var photoDataList: [Data]

    var restaurant: Restaurant?

    init(
        id: UUID = UUID(),
        visitDate: Date = Date(),
        title: String = "",
        notes: String = "",
        rating: Int = 0,
        wouldReturn: Bool = true,
        orderDetails: String = "",
        photoDataList: [Data] = [],
        restaurant: Restaurant? = nil
    ) {
        self.id = id
        self.visitDate = visitDate
        self.title = title
        self.notes = notes
        self.rating = rating
        self.wouldReturn = wouldReturn
        self.orderDetails = orderDetails
        self.photoDataList = photoDataList
        self.restaurant = restaurant
    }
}
