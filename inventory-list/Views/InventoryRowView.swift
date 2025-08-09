//
//  InventoryRowView.swift
//  inventory-list
//
//  Created by Omri Shapira on 02/08/2025.
//


import SwiftUI
import SwiftData

struct InventoryRowView: View {
    let item: InventoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.displayDetails)
                    .font(.headline)
                    .lineLimit(2)
                
                Spacer()
                
                if let quantity = item.quantity {
                    Badge(text: "×\(quantity)", color: .blue)
                }
            }
            
            HStack {
                Label(item.displayBox, systemImage: "shippingbox")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let barcode = item.barcode {
                    Label("\(barcode)", systemImage: "barcode")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let keyword = item.keyword {
                    Badge(text: keyword, color: .green)
                        .font(.caption2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}