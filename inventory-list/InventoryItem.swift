//
//  InventoryItem.swift
//  inventory-list
//
//  Created by Omri Shapira on 02/08/2025.
//

import Foundation

// MARK: - Data Model
struct InventoryItem: Codable, Identifiable {
    let id = UUID()
    let cabinet: Int?
    let shelf: Int?
    let box: Int?
    let barcode: Int?
    let details: String?
    let quantity: Int?
    let image: String?
    let keyword: String?
    
    // Computed properties for display
    var displayDetails: String {
        details ?? "No details"
    }
    
    var displayQuantity: String {
        if let quantity = quantity {
            return "\(quantity)"
        }
        return "N/A"
    }
    
    var displayBox: String {
        if let box = box {
            return "Box \(box)"
        }
        return "No box"
    }
    
    var displayBarcode: String {
        if let barcode = barcode {
            return "\(barcode)"
        }
        return "No barcode"
    }
    
    var locationInfo: String {
        var parts: [String] = []
        if let cabinet = cabinet {
            parts.append("Cabinet \(cabinet)")
        }
        if let shelf = shelf {
            parts.append("Shelf \(shelf)")
        }
        if let box = box {
            parts.append("Box \(box)")
        }
        return parts.isEmpty ? "Location not specified" : parts.joined(separator: " • ")
    }
}
