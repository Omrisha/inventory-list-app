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
    let cabinet: String?
    let shelf: String?
    let box: Int?
    let barcode: String?
    let bag: String?
    let details: String?
    let quantity: Int?
    let comment: String?
    let image: String?
    let keyword: String?
    
    // Custom CodingKeys
        enum CodingKeys: String, CodingKey {
            case cabinet, shelf, box, barcode, bag, details, quantity, comment, image, keyword
        }
        
        // Custom decoder to handle mixed barcode types
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Decode standard optional fields
            cabinet = try container.decodeIfPresent(String.self, forKey: .cabinet)
            shelf = try container.decodeIfPresent(String.self, forKey: .shelf)
            box = try container.decodeIfPresent(Int.self, forKey: .box)
            bag = try container.decodeIfPresent(String.self, forKey: .bag)
            details = try container.decodeIfPresent(String.self, forKey: .details)
            quantity = try container.decodeIfPresent(Int.self, forKey: .quantity)
            comment = try container.decodeIfPresent(String.self, forKey: .comment)
            image = try container.decodeIfPresent(String.self, forKey: .image)
            keyword = try container.decodeIfPresent(String.self, forKey: .keyword)
            
            // Handle mixed barcode types (Int or String)
            if let barcodeInt = try? container.decode(Int.self, forKey: .barcode) {
                barcode = String(barcodeInt)
            } else if let barcodeString = try? container.decode(String.self, forKey: .barcode) {
                barcode = barcodeString
            } else {
                barcode = nil
            }
        }
        
        // Custom encoder
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encodeIfPresent(cabinet, forKey: .cabinet)
            try container.encodeIfPresent(shelf, forKey: .shelf)
            try container.encodeIfPresent(box, forKey: .box)
            try container.encodeIfPresent(barcode, forKey: .barcode)
            try container.encodeIfPresent(bag, forKey: .bag)
            try container.encodeIfPresent(details, forKey: .details)
            try container.encodeIfPresent(quantity, forKey: .quantity)
            try container.encodeIfPresent(comment, forKey: .comment)
            try container.encodeIfPresent(image, forKey: .image)
            try container.encodeIfPresent(keyword, forKey: .keyword)
        }
    
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
        return barcode ?? "No barcode"
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
