//
//  Item.swift
//  Balfala
//
//  Created by Grzegorz Bednarek on 28/10/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
