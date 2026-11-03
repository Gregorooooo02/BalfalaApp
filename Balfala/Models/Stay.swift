import Foundation
import SwiftData

@Model
final class Stay {
    var guestName: String
    var adultsCount: Int
    var childrenCount: Int
    var startDate: Date
    var endDate: Date
    var notes: String?
    
    var house: House?
    
    init(
        guestName: String,
        adultsCount: Int,
        childrenCount: Int,
        startDate: Date,
        endDate: Date,
        notes: String? = nil,
        house: House? = nil
    ) {
        self.guestName = guestName
        self.adultsCount = adultsCount
        self.childrenCount = childrenCount
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.house = house
    }
    
    var numberOfNights: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        
        return max(1, components.day ?? 1)
    }
}
