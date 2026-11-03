import Foundation
import SwiftData

@Model
final class House {
    var id: String          // e.g. "01", "02"
    var name: String        // e.g. "Statua"
    var capacity: Int       // Maximal amount of people
    var isOccupied: Bool
    
    // Relation with stays (optional but could work nicely)
    @Relationship(deleteRule: .nullify, inverse: \Stay.house)
    var stays: [Stay]? = nil
    
    init(id: String, name: String, capacity: Int, isOccupied: Bool) {
        self.id = id
        self.name = name
        self.capacity = capacity
        self.isOccupied = isOccupied
    }
}
