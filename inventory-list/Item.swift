//
//  Item.swift
//  inventory-list
//
//  Created by Omri Shapira on 02/08/2025.
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
